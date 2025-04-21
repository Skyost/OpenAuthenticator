#include <flutter_linux/flutter_linux.h>

#include "my_application.h"
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <pwd.h>
#include <security/pam_appl.h>
#include <sys/types.h>
#include <unistd.h>

#include <iostream>
#include <map>
#include <memory>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
    GtkApplication parent_instance;
    char** dart_entrypoint_arguments;
};

struct pam_response_t {
    const char* password;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

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

static gchar* get_real_name() {
    GError* error = nullptr;
    GDBusConnection* connection = g_bus_get_sync(G_BUS_TYPE_SYSTEM, nullptr, &error);
    if (!connection) return strdup("Unknown");

    gchar* user_path = nullptr;
    GVariant* result = g_dbus_connection_call_sync(
            connection,
            "org.freedesktop.Accounts",
            "/org/freedesktop/Accounts",
            "org.freedesktop.Accounts",
            "FindUserByName",
            g_variant_new("(s)", getenv("USER")),
            G_VARIANT_TYPE("(o)"),
            G_DBUS_CALL_FLAGS_NONE,
            -1,
            nullptr,
            &error
    );

    if (!result) return strdup("Unknown");

    g_variant_get(result, "(&o)", &user_path);

    // Now get the RealName property
    GVariant* name_result = g_dbus_connection_call_sync(
            connection,
            "org.freedesktop.Accounts",
            user_path,
            "org.freedesktop.DBus.Properties",
            "Get",
            g_variant_new("(ss)", "org.freedesktop.Accounts.User", "RealName"),
            G_VARIANT_TYPE("(v)"),
            G_DBUS_CALL_FLAGS_NONE,
            -1,
            nullptr,
            &error
    );

    if (!name_result) return strdup("Unknown");

    GVariant* name_value = nullptr;
    g_variant_get(name_result, "(v)", &name_value);

    const char* real_name = g_variant_get_string(name_value, nullptr);
    return strdup(real_name);
}

static gchar* get_avatar_path() {
  std::string path = "/var/lib/AccountsService/icons/";
  path += getenv("USER");
  return strdup(path.c_str());
}

static int pam_conversation(int num_msg, const struct pam_message** msg, struct pam_response** resp, void* appdata_ptr) {
    struct pam_response_t* data = static_cast<struct pam_response_t*>(appdata_ptr);
    // Allocate response memory
    *resp = static_cast<struct pam_response*>(
    calloc(num_msg, sizeof(struct pam_response)));
  
    if (*resp == nullptr) {
      return PAM_CONV_ERR;
    }

    for (int i = 0; i < num_msg; i++) {
      (*resp)[i].resp = strdup(data->password);
    }

    return PAM_SUCCESS;
}

static void authenticate(const gchar* password, FlMethodCall* method_call) {
    // Get the current username
    struct passwd* pw = getpwuid(getuid());
    if (pw == nullptr) {
        fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_error_response_new("authError", "Cannot get current user.", nullptr)), nullptr);
        return;
    }

    // Set up PAM conversation
    struct pam_response_t data;
    data.password = password;

    struct pam_conv conv;
    conv.conv = pam_conversation;
    conv.appdata_ptr = &data;

    // Start PAM session
    pam_handle_t* pamh = nullptr;
    int ret = pam_start("login", pw->pw_name, &conv, &pamh);
    if (ret != PAM_SUCCESS) {
        fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_error_response_new("authError", "Could not start authentication session.", nullptr)), nullptr);
        return;
    }

    // Try to authenticate
    ret = pam_authenticate(pamh, 0);

    // Clean up
    pam_end(pamh, ret);

    FlValue* success = fl_value_new_bool(ret == PAM_SUCCESS);
    fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_success_response_new(success)), nullptr);
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call, gpointer user_data) {
    const gchar* method = fl_method_call_get_name(method_call);

    if (strcmp(method, "localAuth.isDeviceSupported") == 0) {
        g_autoptr(FlValue) result = fl_value_new_bool(can_authenticate());
        g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
    } else if (strcmp(method, "localAuth.getRealName") == 0) {
        g_autoptr(FlValue) result = fl_value_new_string(get_real_name());
        g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
    } else if (strcmp(method, "localAuth.getAvatarPath") == 0) {
        g_autoptr(FlValue) result = fl_value_new_string(get_avatar_path());
        g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        fl_method_call_respond(method_call, response, nullptr);
    } else if (strcmp(method, "localAuth.authenticate") == 0) {
        FlValue* args = fl_method_call_get_args(method_call);
        FlValue* password = fl_value_lookup_string(args, "password");
        authenticate(fl_value_get_string(password), method_call);
    } else {
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

    FlEngine* engine = fl_view_get_engine(view);

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
    g_set_prgname(APPLICATION_ID);
    return MY_APPLICATION(g_object_new(my_application_get_type(), "application-id", APPLICATION_ID, "flags", G_APPLICATION_HANDLES_COMMAND_LINE | G_APPLICATION_HANDLES_OPEN, nullptr));
}
