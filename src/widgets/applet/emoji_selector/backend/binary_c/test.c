
#include "test.h"

// https://stackoverflow.com/questions/19555121/how-to-get-current-timestamp-in-milliseconds-since-1970-just-the-way-java-gets

unsigned long getTimeStamp()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return 1000000 * tv.tv_sec + tv.tv_usec;
}
/*
bool test_split()
{
    using namespace std;

    string test_string = "testing,test,tested";

    vector<string> tokens = deserializer::split_string(test_string, ",");

    if (tokens[0] != "testing") return false;
    if (tokens[1] != "test") return false;
    if (tokens[2] != "tested") return false;

    return true;
}
*/

void run_test(bool returned, char *name)
{
    printf("Test %s: %s\n", name, returned ? "SUCCESS" : "FAILURE");
}

#define TEST(callback) run_test(callback(), #callback);

int main(void)
{
    const unsigned long time_start = getTimeStamp();

    emoji_LL* list = deserializer_get_category("Animals & Nature");

    struct emoji_LL_node* node = list->head;

    while (node) {
        printf("%s", node->value.emoji);

        node = node->next;
    }
    printf("\n");

    const unsigned long time_end = getTimeStamp();

    LL_destroy(list);

    printf("Deserializer took %lu microseconds\n", time_end - time_start);

    return 0;
}