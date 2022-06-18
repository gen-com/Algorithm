#include <iostream>
#include <cstring>
#include <string>
using namespace std;

int main(void) {
    int testCase;
    string str;
    string firstStr, secondStr;
    int cnt, result;
    
    ios::sync_with_stdio(false);
    result = 0;
    cin >> str;
    firstStr = "0" + str;
    cin >> str;
    secondStr = "0" + str;
        
    int firstLength = (int)firstStr.length();
    int secondLength = (int)secondStr.length();
    int check[firstLength][secondLength];
    memset(check, 0, sizeof(check));
    for (int i = 1; i < firstLength; i++) {
        cnt = 0;
        for (int j = 1; j < secondLength; j++) {
            if (firstStr[i] == secondStr[j]) {
                cnt = check[i - 1][j - 1] + 1;
                check[i][j] = cnt;
            } else {
                if (check[i][j - 1] > check[i - 1][j])
                    check[i][j] = check[i][j - 1];
                else
                    check[i][j] = check[i - 1][j];             
            }
        }
        if (result < cnt)
            result = cnt;
    }
    cout << result << '\n';
    return 0;
}