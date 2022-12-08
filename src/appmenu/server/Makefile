
main: main.cpp
	xxd -i interface.xml > interface.h

	$(CXX) $(CXXFLAGS) main.cpp -o main -O3 `pkg-config --cflags --libs glib-2.0 gio-unix-2.0`

# Save XML to interface.xml
xml:
	cp /usr/share/dbus-1/interfaces/com.canonical.AppMenu.Registrar.xml interface.xml

.PHONY: clean
clean:
	rm -f main