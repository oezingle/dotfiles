
#pragma once

#include <string>
#include <vector>
#include <fstream>
#include <map>

#include <iostream>

// TODO remove tags & categories from header_info, remove split_string, populate tag_indexes & category_indexes more quickly

namespace deserializer
{
    using namespace std;

    const string binary_path = "/home/zingle/.config/awesome/cache/emoji/emoji.bin";

    struct header_info
    {
        map<string, uint8_t> tag_indexes;
        map<string, uint8_t> category_indexes;

        // streampos pos;
    };

    struct emoji
    {
        // TODO might need to be a wstring to interface with Lua properly
        string emoji;
        string description;
    };

    // vector<string> split_string(string&, const string);

    struct emoji deserialize_emoji(char[128]);

    vector<struct emoji> find_category(string term);

    ifstream get_binary_file();

    struct header_info get_header(ifstream &);
}