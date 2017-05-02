#include <vector>
#include <string>
#include <iterator>
#include <iostream>
#include <utility>
#include <algorithm>
#include <limits>
#include <fstream>

int main(int argc, char* argv[])
{
    std::ifstream in{argv[1]};

    std::size_t n;
    in >> n;

    std::vector<std::size_t> elements(n);
    std::copy_n(std::istream_iterator<std::size_t>(in), n, elements.begin());

    std::vector<std::pair<std::size_t,std::size_t>> left_bounds, right_bounds;

    std::size_t cur_min = std::numeric_limits<std::size_t>::max();
    
    for (std::size_t i = 0; i != elements.size(); ++i)
    {
        if (elements[i] < cur_min)
        {
            cur_min = elements[i];
            left_bounds.emplace_back(i, elements[i]);
        }
    }

    std::size_t cur_max = std::numeric_limits<std::size_t>::min();

    for (std::size_t i = elements.size()-1; i != static_cast<std::size_t>(-1); --i)
    {
        if (elements[i] > cur_max)
        {
            cur_max = elements[i];
            right_bounds.emplace_back(i, elements[i]);
        }
    }

    std::size_t maximum_distance = 0;
    std::size_t li = 0, ri = right_bounds.size()-1;

    while (li != left_bounds.size() && ri != static_cast<std::size_t>(-1))
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

    return 0;
}





    



