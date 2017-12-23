#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>

using namespace std;

typedef long long ll;

int main() {

    std::ios_base::sync_with_stdio(false);

    size_t N, L;
    cin >> N >> L;

    vector<ll> cost(N);
    for (size_t i = 0; i != N; ++i)
        cin >> cost[i];

    vector<ll> x(L+1);
    vector<ll> y(L+1, cost[N-1]);

    for (size_t i = N-2; i != static_cast<size_t>(-1); --i) {
        for (size_t l = L; l != 0; --l) {
            x[l] = max(x[l], y[l] - cost[i]);
            y[l] = max(y[l], x[l-1] + cost[i]);
        }
    }

    ll maximum = LONG_MIN;

    for (size_t l = 0; l != L+1; ++l)
        maximum = max(maximum, x[l]);
    
    cout << maximum;

    return 0;
}
