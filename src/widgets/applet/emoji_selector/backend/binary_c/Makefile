
default: test.c deserializer.c emoji_LL.c
	gcc -Wall -Werror test.c deserializer.c emoji_LL.c -O3 -o test

lua: lua.c deserializer.c emoji_LL.c
	gcc -c -Wall -Werror -lstdc++ test.c deserializer.c emoji_LL.c -o out.a
	
	gcc -shared -o libdeserializer.so out.a
	
	rm out.a