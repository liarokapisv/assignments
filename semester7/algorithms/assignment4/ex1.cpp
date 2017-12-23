#include <iostream>
#include <limits>
#include <algorithm>

using ll = long long;


int main()
{
    std::ios_base::sync_with_stdio(false);

    std::size_t N, L;
    std::cin >> N >> L;

    std::vector<ll> cost(N);
    std::vector<ll> maxima;
    maxima.reserve(N);

    for (std::size_t i = 0; i != N; ++i)
        std::cin >> cost[i];

    if (N <= 2)
    {
        maxima = cost;
    }
    else 
    {
        maxima.push_back(cost[0]);
        for (std::size_t i = 1; i != N-1; ++i)
        {
            if ((cost[i-1] <= cost[i] && cost[i] >= cost[i+1]) ||
                (cost[i-1] >= cost[i] && cost[i] <= cost[i+1]))
                    maxima.push_back(cost[i]);

        }
        maxima.push_back(cost[N-1]);
    }

    N = maxima.size();

    std::vector<ll> n0(L+1);
    std::vector<ll> n1(L+1, -maxima[0]);

    for (std::size_t i = 1; i != N; ++i)
    {
        for (std::size_t l = L; l != 0; --l)
        {
            n0[l] = std::max(+maxima[i]+n1[l], n0[l]);
            n1[l] = std::max(-maxima[i]+n0[l-1], n1[l]);
        }
    }

    std::cout << *std::max_element(n0.begin(), n0.end()) << "\n";
}


