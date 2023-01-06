
#pragma once

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#include "emoji_LL.h"
#include "emoji.h"

emoji deserialize_emoji(char*);

FILE *deserializer_get_binary_file();

// Indexes from 1
__uint8_t deserializer_get_category_index(FILE* binary, char *category);

// Indexes from 1
__uint8_t deserializer_get_tag_index(FILE* binary, char *tag);

emoji_LL* deserializer_get_category(char *category);