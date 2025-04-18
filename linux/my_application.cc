#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <memory>
#include <string>
#include <map>

#include <gio/gio.h>
#include <polkit/polkit.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

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

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call, gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "localAuth.isDeviceSupported") == 0) {
    g_autoptr(FlValue) result = fl_value_new_bool(can_authenticate());
    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
  } else if (strcmp(method, "localAuth.authenticate") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    FlValue* reason = fl_value_lookup_string(args, "reason");
    authenticate(reason, method_call);
  }
  else {
    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    fl_method_call_respond(method_call, response, nullptr);
  }
}

static gboolean can_authenticate() {
  // Check if polkit is available on the system
  GError* error = nullptr;
  GDBusConnection* connection = g_bus_get_sync(G_BUS_TYPE_SYSTEM, nullptr, &error);

  if (error != nullptr) {
    g_error_free(error);
    return FALSE;
  }

  // Check if polkit service is available
  GDBusProxy* proxy = g_dbus_proxy_new_sync(connection, G_DBUS_PROXY_FLAGS_NONE, nullptr, "org.freedesktop.PolicyKit1", "/org/freedesktop/PolicyKit1/Authority", "org.freedesktop.PolicyKit1.Authority", nullptr, &error);

  g_object_unref(connection);

  if (error != nullptr) {
    g_error_free(error);
    return FALSE;
  }

  g_object_unref(proxy);
  return TRUE;
}

static void authenticate(const std::string& reason, FlMethodCall* method_call) {
  GError* error = nullptr;
  PolkitAuthority* authority = polkit_authority_get_sync(nullptr, &error);

  if (error != nullptr) {
    fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_error_response_new("authInitError", error->message, nullptr)), nullptr);
    g_error_free(error);
    return;
  }

  // Create a polkit subject for the current process
  pid_t pid = getpid();
  PolkitSubject* subject = polkit_unix_process_new(pid);

  // The action ID to use - you may need to create a custom policy for this
  const char* action_id = "org.freedesktop.policykit.exec";

  // Create a cancellable for the authentication
  GCancellable* cancellable = g_cancellable_new();

  // Store the result and authority in a pair to be used in the callback
  auto* result_pair = new std::pair<FlMethodCall*, PolkitAuthority*>(method_call, authority);

  // Check authorization with interactive flag set to true
  polkit_authority_check_authorization(authority, subject, action_id,
                                       nullptr,  // PolkitDetails
                                       POLKIT_CHECK_AUTHORIZATION_FLAGS_ALLOW_USER_INTERACTION,
                                       cancellable,
                                       auth_callback,
                                       result_pair);

  g_object_unref(subject);
  g_object_unref(cancellable);
}

// The authentication callback for polkit
static void auth_callback(GObject* source_object, GAsyncResult* res, gpointer user_data) {
  GError* error = nullptr;
  auto result_pair = static_cast<std::pair<FlMethodCall*, PolkitAuthority*>*>(user_data);
  auto method_call = std::move(result_pair->first);
  PolkitAuthority* authority = result_pair->second;

  PolkitAuthorizationResult* auth_result = polkit_authority_check_authorization_finish(
    authority, res, &error
  );

  if (error != nullptr) {
    fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_error_response_new("authError", error->message, nullptr)), nullptr);
    g_error_free(error);
  } else {
    bool is_authorized = polkit_authorization_result_get_is_authorized(auth_result);
    fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_success_response_new(is_authorized)), nullptr);
    g_object_unref(auth_result);
  }

  g_object_unref(authority);
  delete result_pair;
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
