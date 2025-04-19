#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <memory>
#include <map>
#include <iostream>

#include <security/pam_appl.h>
#include <pwd.h>
#include <unistd.h>
#include <sys/types.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

// Simple structure to pass data to the PAM conversation function
struct pam_response_t {
  const char* username;
  const char* reason;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// PAM Conversation function
static int pam_conversation(int num_msg, const struct pam_message** msg, struct pam_response** resp, void* appdata_ptr) {
  struct pam_response_t* data = static_cast<struct pam_response_t*>(appdata_ptr);

  // Allocate response memory
  *resp = static_cast<struct pam_response*>(
  calloc(num_msg, sizeof(struct pam_response)));

  if (*resp == nullptr) {
    return PAM_CONV_ERR;
  }

  // Simple prompt using GTK or a terminal prompt could be added here
  // For now, we'll just return empty responses which will trigger the system's
  // own authentication prompt
  for (int i = 0; i < num_msg; i++) {
    if (msg[i]->msg_style == PAM_PROMPT_ECHO_OFF) {
      std::string escaped_reason = data->reason;
      for (size_t i = 0; i < escaped_reason.length(); i++) {
        if (escaped_reason[i] == '"') {
          escaped_reason.insert(i, "\\");
          i++;
        }
      }
      std::string password = "";
      if (system("which zenity >/dev/null 2>&1") == 0) {
        std::string cmd = "zenity --password --title=\"" + escaped_reason + "\" >/dev/null 2>&1";
        password = system(cmd.c_str());
      }
      
      (*resp)[i].resp = strdup(password.c_str());
    } else if (msg[i]->msg_style == PAM_TEXT_INFO) {
      if (system("which zenity >/dev/null 2>&1") == 0) {
        std::string escaped_msg = msg[i]->msg;
        for (size_t i = 0; i < escaped_msg.length(); i++) {
          if (escaped_msg[i] == '"') {
            escaped_msg.insert(i, "\\");
            i++;
          }
        }
        std::string cmd = "zenity --info --text=\"" + escaped_msg + "\" >/dev/null 2>&1";
        system(cmd.c_str());
      } else {
        std::cout << msg[i]->msg << std::endl;
      }
    } else {
        free(*resp);
        return PAM_CONV_ERR;
    }
  }

  return PAM_SUCCESS;
}

static gboolean can_authenticate() {
  pam_handle_t* pamh = nullptr;
  struct pam_conv conv = {nullptr, nullptr};
  
  int ret = pam_start("login", nullptr, &conv, &pamh);
  if (ret != PAM_SUCCESS) {
    return FALSE;
  }
  
  pam_end(pamh, ret);
  return TRUE;
}

static void authenticate(const gchar* reason, FlMethodCall* method_call) {
  // Get the current username
  struct passwd *pw = getpwuid(getuid());
  if (pw == nullptr) {
    fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_error_response_new("authError", "Cannot get current user.", nullptr)), nullptr);
    return;
  }
  
  // Set up PAM conversation
  struct pam_response_t data;
  data.username = pw->pw_name;
  data.reason = reason;
  
  struct pam_conv conv;
  conv.conv = pam_conversation;
  conv.appdata_ptr = &data;
  
  // Start PAM session
  pam_handle_t* pamh = nullptr;
  int ret = pam_start("login", data.username, &conv, &pamh);
  if (ret != PAM_SUCCESS) {
    fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_error_response_new("authError", "Could not start authentication session.", nullptr)), nullptr);
    return;
  }
  
  // Try to authenticate
  ret = pam_authenticate(pamh, 0);
  
  // Clean up
  pam_end(pamh, ret);
  
  std::cout << data.username << std::endl;
  std::cout << ret << std::endl;
  FlValue* success = fl_value_new_bool(ret == PAM_SUCCESS);
  fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_success_response_new(success)), nullptr);
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call, gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "localAuth.isDeviceSupported") == 0) {
    g_autoptr(FlValue) result = fl_value_new_bool(can_authenticate());
    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  } else if (strcmp(method, "localAuth.authenticate") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    FlValue* reason = fl_value_lookup_string(args, "reason");
    authenticate(fl_value_get_string(reason), method_call);
  }
  else {
    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    fl_method_call_respond(method_call, response, nullptr);
  }
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  GList* windows = gtk_application_get_windows(GTK_APPLICATION(application));
  if (windows) {
    gtk_window_present(GTK_WINDOW(windows->data));
    return;
  }

  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "Open Authenticator");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "Open Authenticator");
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  FlEngine *engine = fl_view_get_engine(view);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlBinaryMessenger) messenger = fl_engine_get_binary_messenger(engine);
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(messenger, "app.openauthenticator.localauth", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb, g_object_ref(view), g_object_unref);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return FALSE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_HANDLES_COMMAND_LINE | G_APPLICATION_HANDLES_OPEN,
                                     nullptr));
}
