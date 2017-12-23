#include <algorithm>
#include <vector>
#include <iostream>

using ll = long long;

bool redundant(std::vector<ll>& Y, std::vector<ll>& X, std::size_t l1, std::size_t l2, std::size_t l3)
{
    return (Y[l3]-Y[l1])*(X[l1]-X[l2])<(Y[l2]-Y[l1])*(X[l1]-X[l3]);
}

void add(std::vector<ll>& Y, std::vector<ll>& X, long long m,long long b)
{
    X.push_back(m);
    Y.push_back(b);
    while (X.size()>=3 && redundant(Y, X, X.size()-3, X.size()-2, X.size()-1))
    {
        X.erase(X.end()-2);
        Y.erase(Y.end()-2);
    }
}

long long query(std::vector<ll>& Y, std::vector<ll>& X, long long x)
{
    static std::size_t pointer = 0;

    if (pointer >=X.size())
        pointer=X.size()-1;
    while (pointer<X.size()-1&&
            X[pointer+1]*x+Y[pointer+1]>X[pointer]*x+Y[pointer])
        pointer++;
    return X[pointer]*x+Y[pointer];
}


int main() {

    std::ios_base::sync_with_stdio(false);

    ll N, a, b, c;
    std::cin >> N;

    std::cin >> a >> b >> c;

    std::vector<int> x(N+1);
    std::vector<ll> sum(N+1);

    std::vector<ll> dp(N+1);

    std::vector<ll> X;
    std::vector<ll> Y;

    for(int i = 1 ; i <= N ; i++){
        std::cin >> x[i];
        sum[i] = sum[i - 1] + x[i];
    }

    dp[1] = a * x[1] * x[1] + b * x[1] + c;
    add(Y, X, -2 * a * x[1] , dp[1] + a * x[1] * x[1] - b * x[1]);

    for(int i = 2 ; i <= N ; i++) {
        dp[i] = a * sum[i] * sum[i] + b * sum[i] + c + std::max(0LL, query(Y, X, sum[i]));
        add(Y, X, -2 * a * sum[i] , dp[i] + a * sum[i] * sum[i] - b * sum[i]);
    }

    std::cout << dp[N] << "\n";

    return 0;
}
