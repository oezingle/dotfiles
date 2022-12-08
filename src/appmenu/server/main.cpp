/**
 * A DBus server that allows some clients to register menus
 * Other apps have _GTK_MENUBAR_OBJECT_PATH Xprops thanks to appmenu-gtk-module
 * In short, QT / non-pure gtk apps will publish menus by X11 WindowID to the database 
 * maintained by this server.
 * 
 * Interface: /usr/share/dbus-1/interfaces/com.canonical.AppMenu.Registrar.xml
 * 
 * Don't ever use this code as a guide - it sucks and mixes C/C++ paradigms
 * 
 * Check out implementation using d-feet
 **/ 

// TODO make sure that only one instance runs

// Clients seem to know to hide their menus if they can register menus

#include <gio/gio.h>
#include <stdlib.h>

#ifdef G_OS_UNIX
#include <gio/gunixfdlist.h>
/* For STDOUT_FILENO */
#include <unistd.h>
#endif

#include <string.h>


#include "interface.h"

#include <map>

/* ---------------------------------------------------------------------------------------------------- */

static GDBusNodeInfo *introspection_data = NULL;

/* Introspection data for the service we are exporting */
static const gchar *introspection_xml = (const gchar *)interface_xml;

#define DBUS_INTERFACE_NAME "com.canonical.AppMenu.Registrar"
#define DBUS_INTERFACE_PATH "/com/canonical/AppMenu/Registrar"

/** could maybe be a std::pair? **/
typedef struct DBusInfo
{
  gchar *menuObjectPath;
  gchar *service;
} DBusInfo;

static std::map<guint32, DBusInfo> menuMap;

/* ---------------------------------------------------------------------------------------------------- */

static void
handle_method_call(GDBusConnection *connection,
                   const gchar *sender,
                   const gchar *object_path,
                   const gchar *interface_name,
                   const gchar *method_name,
                   GVariant *parameters,
                   GDBusMethodInvocation *invocation,
                   gpointer user_data)
{
  if (g_strcmp0(method_name, "RegisterWindow") == 0)
  {
    guint32 windowId = 0;
    gchar *menuObjectPath;

    g_variant_get(parameters, "(uo)", &windowId, &menuObjectPath);

    g_print("XWindow %u: register\n", windowId);

    unsigned sender_len = strlen((gchar *)sender) + 1;
    gchar *sender_cp = (gchar *)malloc(sizeof(gchar) * sender_len);

    strcpy(sender_cp, sender);

    menuMap[windowId] = {menuObjectPath, sender_cp};

    g_dbus_method_invocation_return_value(invocation, NULL);
  }
  else if (g_strcmp0(method_name, "UnregisterWindow") == 0)
  {
    guint32 windowId = 0;

    g_variant_get(parameters, "(u)", &windowId);

    g_print("XWindow %u: unregister\n", windowId);

    auto menuForWindowIter = menuMap.find(windowId);

    if (menuForWindowIter != menuMap.end())
    {
      auto menuForWindow = menuForWindowIter->second;

      g_free(menuForWindow.menuObjectPath);
      g_free(menuForWindow.service);

      menuMap.erase(windowId);

      g_dbus_method_invocation_return_value(invocation, NULL);
    }
    else
    {
      g_dbus_method_invocation_return_error(
          invocation,
          G_IO_ERROR,
          G_IO_ERROR_FAILED_HANDLED,
          "XWindow requested has not registered a menu");
    }
  }
  else if (g_strcmp0(method_name, "GetMenuForWindow") == 0)
  {
    guint32 windowId = 0;

    g_variant_get(parameters, "(u)", &windowId);

    auto menuForWindowIter = menuMap.find(windowId);

    if (menuForWindowIter != menuMap.end())
    {
      // Return shit
      auto menuForWindow = menuForWindowIter->second;

      g_dbus_method_invocation_return_value(
          invocation,
          g_variant_new(
              "(so)",
              menuForWindow.service,
              menuForWindow.menuObjectPath));
    }
    else
    {
      g_dbus_method_invocation_return_error(
          invocation,
          G_IO_ERROR,
          G_IO_ERROR_FAILED_HANDLED,
          "XWindow requested has not registered a menu");
    }
  }
}

static const GDBusInterfaceVTable interface_vtable =
    {
        handle_method_call,
};

/* ---------------------------------------------------------------------------------------------------- */

static void
on_bus_acquired(GDBusConnection *connection,
                const gchar *name,
                gpointer user_data)
{
  guint registration_id;

  registration_id = g_dbus_connection_register_object(
      connection,
      DBUS_INTERFACE_PATH,
      introspection_data->interfaces[0],
      &interface_vtable,
      NULL,  /* user_data */
      NULL,  /* user_data_free_func */
      NULL); /* GError** */

  g_assert(registration_id > 0);

  /* swap value of properties Foo and Bar every two seconds */
  /*g_timeout_add_seconds (2,
                         on_timeout_cb,
                         connection);*/
}

static void
on_name_acquired(GDBusConnection *connection,
                 const gchar *name,
                 gpointer user_data)
{
}

static void
on_name_lost(GDBusConnection *connection,
             const gchar *name,
             gpointer user_data)
{
  exit(1);
}

int main(int argc, char *argv[])
{
  g_print("Simple com.canonical.AppMenu.Registrar DBus server\nBy Oscar Zingle | (c)2022\n");

  guint owner_id;
  GMainLoop *loop;

  g_type_init();

  /* We are lazy here - we don't want to manually provide
   * the introspection data structures - so we just build
   * them from XML.
   */
  introspection_data = g_dbus_node_info_new_for_xml(introspection_xml, NULL);
  g_assert(introspection_data != NULL);

  owner_id = g_bus_own_name(G_BUS_TYPE_SESSION,
                            DBUS_INTERFACE_NAME,
                            G_BUS_NAME_OWNER_FLAGS_NONE,
                            on_bus_acquired,
                            on_name_acquired,
                            on_name_lost,
                            NULL,
                            NULL);

  loop = g_main_loop_new(NULL, FALSE);
  g_main_loop_run(loop);

  g_bus_unown_name(owner_id);

  g_dbus_node_info_unref(introspection_data);

  return 0;
}