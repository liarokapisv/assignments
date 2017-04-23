#include <vector>
#include <string>
#include <iterator>
#include <iostream>
#include <utility>
#include <algorithm>
#include <climits>

int main()
{
    int n;
    std::cin >> n;

    std::vector<int> elements(n);
    std::copy_n(std::istream_iterator<int>(std::cin), n, elements.begin());

    std::vector<std::pair<int,int>> left_bounds, right_bounds;

    int cur_min = INT_MAX;
    
    for (int i = 0; i < elements.size(); ++i)
    {
        if (elements[i] < cur_min)
        {
            cur_min = elements[i];
            left_bounds.emplace_back(i, elements[i]);
        }
    }

    int cur_max = INT_MIN;

    for (int i = elements.size()-1; i >= 0; --i)
    {
        if (elements[i] > cur_max)
        {
            cur_max = elements[i];
            right_bounds.emplace_back(i, elements[i]);
        }
    }

    int maximum_distance = 0;
    int li = 0, ri = right_bounds.size()-1;

    while (li < left_bounds.size() && ri >= 0)
    {
        auto left_bound = left_bounds[li];
        auto right_bound = right_bounds[ri];

        if (left_bound.second > right_bound.second)
        {
            ++li;
        }
        else
        {
            maximum_distance = std::max(right_bound.first - left_bound.first, maximum_distance);
            --ri;
        }
    }

    std::cout << maximum_distance << '\n';
}





    



