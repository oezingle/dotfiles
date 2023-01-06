
#include "deserializer.hpp"

namespace deserializer
{
    // https://stackoverflow.com/questions/14265581/parse-split-a-string-in-c-using-string-delimiter-standard-c
    /*
    vector<string> split_string(string &s, const string delimiter)
    {
        vector<string> out;

        size_t pos = 0;
        string token;
        while ((pos = s.find(delimiter)) != string::npos)
        {
            token = s.substr(0, pos);

            out.push_back(token);

            s.erase(0, pos + delimiter.length());
        }

        // There is one final token
        out.push_back(s);

        return out;
    };
    */

    void add_indexes(string &s, map<string, uint8_t> &indexes)
    {
        uint8_t index = 0;

        size_t pos = 0;
        string token;
        while ((pos = s.find("|")) != string::npos)
        {
            token = s.substr(0, pos);

            indexes[token] = index;

            index++;

            s.erase(0, pos + 1);
        }

        // There is one final token
        indexes[s] = index;
    }

    struct emoji deserialize_emoji(char chunk[128])
    {
        struct emoji out;

        string character(chunk);
        out.emoji = character;

        string description(chunk + 33);
        out.description = description;

        return out;
    }

    vector<struct emoji> find_category(string term)
    {
        ifstream file = get_binary_file();

        struct header_info header = get_header(file);

        // No category by that name
        if (!header.category_indexes.count(term))
        {
            vector<struct emoji> ret;

            return ret;
        }

        uint8_t category_index = header.category_indexes[term];

        uint8_t current_header_index = 0;

        char test_chunk;
        while (current_header_index < category_index)
        {
            file.read(&test_chunk, 1);

            file.seekg(127, ios::cur);

            if (test_chunk == '\0')
            {
                current_header_index++;

                file.seekg(1, ios::cur);
            }
        }

        file.seekg(-128, ios::cur);

        vector<struct emoji> emojis(256);

        char *chunk = new char[128];

        unsigned index = 0;

        while (true)
        {
            file.read(chunk, 128);

            if (chunk[0] == '\0')
                break;

            emojis[index++] = deserialize_emoji(chunk);
        }
        
        emojis.shrink_to_fit();

        return emojis;
    }

    ifstream get_binary_file()
    {
        ifstream file;

        file.open(binary_path, ios::in | ios::binary);

        if (!file.good())
            throw "No file";

        file.seekg(16);

        return file;
    }

    struct header_info get_header(ifstream &file)
    {
        // Get tags
        string tag_line;
        if (!getline(file, tag_line))
            throw "getline error";

        map<string, uint8_t> tag_indexes;
        add_indexes(tag_line, tag_indexes);

        // Get categories
        string category_line;
        if (!getline(file, category_line))
            throw "getline error";

        map<string, uint8_t> category_indexes;
        add_indexes(category_line, category_indexes);

        struct header_info header;

        header.tag_indexes = tag_indexes;
        header.category_indexes = category_indexes;

        /*
        char* chunk = new char[128];
        file.read(chunk, 128);
        */

        // header.pos = file.tellg();

        return header;
    }
};
