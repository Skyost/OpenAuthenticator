#include <flutter_linux/flutter_linux.h>

#include "my_application.h"
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <polkit/polkit.h>

#include <iostream>
#include <map>
#include <memory>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
    GtkApplication parent_instance;
    char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void can_authenticate(FlMethodCall* method_call) {
    GError* error = nullptr;
    PolkitAuthority* authority = polkit_authority_get_sync(nullptr, &error);
    if (error) {
        fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_error_response_new("authCheckError", error->message, nullptr)), nullptr);
        g_clear_error(&error);
        return;
    }
    if (authority == nullptr) {
        fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(false))), nullptr);
        return;
    }
    fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true))), nullptr);
}

static void authenticate_async_callback(PolkitAuthority* authority, GAsyncResult* result, gpointer user_data) {
    GError* error = nullptr;

    // Retrieve the result from the async operation
    PolkitAuthorizationResult* auth_result = polkit_authority_check_authorization_finish(authority, result, &error);

    if (error) {
        std::cout << error->message << std::endl;
        fl_method_call_respond((FlMethodCall*)user_data, FL_METHOD_RESPONSE(fl_method_error_response_new("authError", error->message, nullptr)), nullptr);
        g_clear_error(&error);
        g_object_unref(user_data);
        return;
    }
    if (auth_result == nullptr) {
        fl_method_call_respond((FlMethodCall*)user_data, FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(false))), nullptr);
        g_object_unref(user_data);
        return;
    }

    gboolean success = polkit_authorization_result_get_is_authorized(auth_result);
    fl_method_call_respond((FlMethodCall*)user_data, FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(success))), nullptr);

    g_object_unref(user_data); // Unref the method call after use
}

static void authenticate(FlMethodCall* method_call) {
    GError* error = nullptr;
    PolkitAuthority* authority = polkit_authority_get_sync(nullptr, &error);
    if (error || authority == nullptr) {
        fl_method_call_respond(method_call, FL_METHOD_RESPONSE(fl_method_error_response_new("authError", error->message, nullptr)), nullptr);
        return;
    }

    PolkitSubject* subject = polkit_unix_process_new_for_owner(getpid(), 0, -1);
    polkit_authority_check_authorization(
        authority,
        subject,
        "app.openauthenticator.authenticate",
        nullptr,
        POLKIT_CHECK_AUTHORIZATION_FLAGS_ALLOW_USER_INTERACTION,
        nullptr,
        (GAsyncReadyCallback) authenticate_async_callback,
        g_object_ref(method_call)
    );
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call, gpointer user_data) {
    const gchar* method = fl_method_call_get_name(method_call);

    if (strcmp(method, "localAuth.isDeviceSupported") == 0) {
        can_authenticate(method_call);
    } else if (strcmp(method, "localAuth.authenticate") == 0) {
        authenticate(method_call);
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
