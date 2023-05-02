#include <glib.h>
#include <gio/gio.h>
#include <stdio.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <stdbool.h>

// D-Bus service name and object path
#define SERVICE_NAME "org.awesomewm.cli"
#define OBJECT_PATH "/org/awesomewm/cli"

// D-Bus method name and interface
#define METHOD_NAME "SendCommand"
#define INTERFACE_NAME "org.awesomewm.cli"

// D-Bus signal name
#define SIGNAL_NAME "Print"

// D-Bus timeout in milliseconds
#define TIMEOUT_MS 5000

// GLib main loop
GMainLoop *loop = NULL;

// D-Bus connection and proxy
GDBusConnection *connection = NULL;
GDBusProxy *proxy = NULL;

// D-Bus signal handler
void on_signal_received(GDBusProxy *proxy, gchar *sender_name, gchar *signal_name, GVariant *parameters, gpointer user_data)
{
    const gchar *msg;
    g_variant_get(parameters, "(s)", &msg);

    g_print("Received signal %s from %s: %s\n", signal_name, sender_name, msg);
}

// TODO works but definitely leaks a fuck ton of memory
// also the prompt should wait for proxy to return

// Command line callback
void command_line_callback(char *input)
{
    // Create a new D-Bus message
    GDBusMessage *message = g_dbus_message_new_method_call(SERVICE_NAME, OBJECT_PATH, INTERFACE_NAME, METHOD_NAME);

    // Set the message arguments
    GVariant *args = g_variant_new("(s)", input);
    g_dbus_message_set_body(message, args);

    // Send the message asynchronously
    GDBusProxyFlags flags = G_DBUS_PROXY_FLAGS_NONE;
    GError *error = NULL;
    g_dbus_proxy_call(proxy, METHOD_NAME, args, flags, TIMEOUT_MS, NULL, NULL, NULL);

    // Free resources
    g_object_unref(message);
}

// readline docs https://tiswww.case.edu/php/chet/readline/readline.html#Programming-with-GNU-Readline

void *signal_thread(void *args)
{
    // Register a signal handler for the service
    GDBusProxyFlags signal_flags = G_DBUS_PROXY_FLAGS_NONE;
    g_signal_connect(proxy, "g-signal", G_CALLBACK(on_signal_received), NULL);

    // Start the GLib main loop
    loop = g_main_loop_new(NULL, FALSE);

    g_main_loop_run(loop);

    g_thread_exit(g_thread_self());

    return NULL;
}

int main(int argc, char *argv[])
{
    // Initialize GLib and D-Bus
#if !GLIB_CHECK_VERSION(2, 35, 0)
    g_type_init();
#endif

    g_bus_own_name(G_BUS_TYPE_SESSION, SERVICE_NAME, G_BUS_NAME_OWNER_FLAGS_NONE, NULL, NULL, NULL, NULL, NULL);

    // TODO leaks on error
    // Connect to the D-Bus session bus
    GError *error = NULL;
    connection = g_bus_get_sync(G_BUS_TYPE_SESSION, NULL, &error);
    if (connection == NULL)
    {
        g_print("Error connecting to D-Bus: %s\n", error->message);
        g_error_free(error);
        return 1;
    }

    // Create a D-Bus proxy for the service
    proxy = g_dbus_proxy_new_sync(connection, G_DBUS_PROXY_FLAGS_NONE, NULL, SERVICE_NAME, OBJECT_PATH, INTERFACE_NAME, NULL, &error);
    if (proxy == NULL)
    {
        g_print("Error creating D-Bus proxy: %s\n", error->message);
        g_error_free(error);
        return 1;
    }

    // create thread for signals
    GThread *thread = g_thread_new("signals", &signal_thread, NULL);

    // Initialize the Readline library
    rl_initialize();

    // Readline needs updates
    // https://stackoverflow.com/questions/9300974/gnu-readline-libreadline-displaying-output-message-asynchronously

    while (true)
    {
        char *buffer = readline(" > ");

        if (buffer && *buffer)
        {
            command_line_callback(buffer);

            add_history(buffer);
        }
    }

    g_thread_join(thread);

    // TODO valgrind this
    // Clean up resources
    g_main_loop_unref(loop);
    g_free(loop);

    g_free(proxy);

    g_dbus_connection_close_sync(connection, NULL, NULL);
    g_free(connection);

    return 0;
}