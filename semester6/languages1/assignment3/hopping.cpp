#include <fstream>
#include <iterator>
#include <vector>
#include <string>
#include <sstream>
#include <algorithm>
#include <iostream>

std::size_t hopper(std::vector<std::pair<bool,std::size_t>>& memoized,
        const std::vector<std::vector<std::size_t>>& valid_steps,
        std::size_t limit,
        std::size_t n)
{
    auto& memo = memoized[n];
    if (memo.first == true) return memo.second;

    if (n == 1) 
    {
        memo.second = 1;
        memo.first = true;
        return 1;
    }

    std::size_t sum = 0;
    for (const auto& step : valid_steps[n])
    {
        sum = (hopper(memoized, valid_steps, limit, n - step) + sum)  % limit;
    }

    memo.second = sum;
    memo.first = true;
    return sum;

}

int main(int argc, char* argv[]) {
    std::ifstream in {argv[1]};
    std::string line;
    std::getline(in, line);
    std::istringstream ss(line);

    std::size_t N, K, B;
    ss >> N >> K >> B;

    std::getline(in, line);
    ss.str(line);
    ss.clear();
    std::vector<std::size_t> steps;
    std::copy_n(std::istream_iterator<std::size_t>(ss), K, std::back_inserter(steps));

    std::getline(in, line);
    ss.str(line);
    ss.clear();
    std::vector<std::size_t> invalid_stairs;
    std::copy_n(std::istream_iterator<std::size_t>(ss), B, std::back_inserter(invalid_stairs));

    std::vector<bool> is_invalid_stair(N+1,false);
    for (auto& stair : invalid_stairs)
    {
        is_invalid_stair[stair] = true;
    }

    std::vector<std::vector<std::size_t>> valid_steps(N+1, steps);
    for (std::size_t i = 0; i != N+1; ++i)
    {
        valid_steps[i].erase(
                std::remove_if(valid_steps[i].begin(), valid_steps[i].end(), 
                    [i,&is_invalid_stair](std::size_t s) { return (s >= i || is_invalid_stair[i-s]); }),
                valid_steps[i].end());
    }

    std::vector<std::pair<bool,std::size_t>> memoized(N+1, std::make_pair(false, 0));

    for (std::size_t i = 1; i != N+1; ++i)
    {
        hopper(memoized,valid_steps,1000000009,i);
    }

    std::cout << hopper(memoized, valid_steps, 1000000009, N) << std::endl;

    return 0;
}

