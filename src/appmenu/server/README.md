
# Simple-Appmenu-Server

A dead simple DBus server using Glib/Gio to publish the com.canonical.AppMenu.Registrar DBus interface over dbus.

## What does it do?
QT and 'impure' GTK apps can publish their DBus service names to the com.canonical.AppMenu.Registrar database, indexed by their X11 Window ID, so we can grab their menus at a later date. 'Pure' GTK apps don't do this, but paired with `appmenu-gtk-module` from `vala-panel` publish the X11 properties `_GTK_UNIQUE_BUS_NAME` and `_GTK_MENUBAR_OBJECT_PATH` with a different format of menu.

