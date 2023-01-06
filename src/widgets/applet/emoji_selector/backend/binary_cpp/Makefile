
default: test.cpp deserializer.cpp
	gcc -Wall -Werror -lstdc++ test.cpp deserializer.cpp -o test

lua: lua.cpp deserializer.cpp
	gcc -c -Wall -Werror -lstdc++ test.cpp deserializer.cpp -o out.a
	
	gcc -shared -o libdeserializer.so out.a
	
	rm out.a