
#include "test.hpp"

// https://stackoverflow.com/questions/19555121/how-to-get-current-timestamp-in-milliseconds-since-1970-just-the-way-java-gets
uint64_t timeSinceEpochMillisec() {
  using namespace std::chrono;
  return duration_cast<microseconds>(system_clock::now().time_since_epoch()).count();
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

void run_test (bool returned, std::string name) {
    using namespace std;

    cout << "Test " << name << ": " << (returned ? "SUCCESS" : "FAILURE") << endl;
}

#define TEST(callback) run_test(callback(), #callback);

int main(void)
{
    using namespace std;

    const uint64_t time_start = timeSinceEpochMillisec();

    vector<struct deserializer::emoji> matches = deserializer::find_category("Animals & Nature");

    for (auto& match : matches) {
        cout << match.emoji;
    }

    cout << endl;

    const uint64_t time_end = timeSinceEpochMillisec();

    cout << "Deserializing the header took " << time_end - time_start << " microseconds" << endl;
}