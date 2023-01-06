
#include "deserializer.h"

const char *deserializer_binary_path = "/home/zingle/.config/awesome/cache/emoji/emoji.bin";

#define DESCRIPTION_OFFSET 33

emoji deserialize_emoji(char *chunk)
{
    emoji out;

    size_t emoji_len = strlen(chunk);
    char *emoji = malloc(sizeof(char) * (emoji_len + 1));
    emoji[emoji_len] = '\0';
    strcpy(emoji, chunk);

    out.emoji = emoji;

    size_t description_len = strlen(chunk + DESCRIPTION_OFFSET);
    char *description = malloc(sizeof(char) * (description_len + 1));
    description[description_len] = '\0';
    strcpy(description, chunk + DESCRIPTION_OFFSET);

    out.description = description;

    return out;
}

FILE *deserializer_get_binary_file()
{
    return fopen(deserializer_binary_path, "rb");
}

// index from 1. 0 if Not exists
__uint8_t deserializer_string_index(FILE *binary, char *match)
{
    __uint8_t list_index = 1;

    char c;

    bool list_partial_match = true;
    bool list_match = false;
    __uint8_t list_string_index = 0;

    while ((c = fgetc(binary)) != EOF)
    {
        if (c == '|')
        {
            if (!list_match)
            {
                if (list_partial_match)
                    list_match = true;

                list_string_index = 0;
                list_partial_match = true;
                list_index++;
            }
        }
        else if (c == '\n')
        {
            if (list_match)
                return list_index;

            break;
        }
        else
        {
            if (list_partial_match && match[list_string_index] != c)
                list_partial_match = false;

            list_string_index++;
        }
    }

    return 0;
}

// Indexes from 1
__uint8_t deserializer_get_category_index(FILE *binary, char *category)
{
    fseek(binary, 16, SEEK_SET);

    //  Skip through tags
    char c;

    while ((c = fgetc(binary)) != '\n' && c != EOF)
        ;

    __uint8_t index = deserializer_string_index(binary, category);

    return index;
}

// Indexes from 1
__uint8_t deserializer_get_tag_index(FILE *binary, char *tag)
{
    fseek(binary, 16, SEEK_SET);

    __uint8_t index = deserializer_string_index(binary, tag);

    // Skip through categories
    char c;

    while ((c = fgetc(binary)) != '\n' && c != EOF)
        ;

    return index;
}

emoji_LL *deserializer_get_category(char *category)
{
    emoji_LL *list = LL_create();

    FILE *file = deserializer_get_binary_file();

    __uint8_t category_index = deserializer_get_category_index(file, category);

    if (category_index != 0)
    {
        __uint8_t header_category_index = 2;

        while (header_category_index < category_index)
        {
            char c = fgetc(file);

            fseek(file, 127, SEEK_CUR);

            if (c == '\0')
            {
                header_category_index++;

                fseek(file, 1, SEEK_CUR);
            }
        }

        fseek(file, -128, SEEK_CUR);

        char *chunk = malloc(sizeof(char) * 128);

        while (true)
        {
            fread(chunk, 1, 128, file);

            if (chunk[0] == '\0')
                break;

            LL_append(list, deserialize_emoji(chunk));
        }

        free(chunk);
    }

    fclose(file);

    return list;
}