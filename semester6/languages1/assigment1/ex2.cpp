
#include <tuple>
#include <queue>
#include <algorithm>
#include <vector>
#include <iostream>
#include <utility>
#include <string>
#include <iterator>
#include <fstream>
#include <memory>
#include <type_traits>
#include <cstdlib>

using node_t = std::tuple<bool, std::size_t, std::size_t>;

template <typename Access>
class path_iterable 
{
private:
    Access _acc;
    node_t _cur;
    node_t _start;

public:
    path_iterable(Access acc, node_t cur, node_t start) : _acc{acc}, _cur{cur} , _start{start} {}

    class const_iterator : public std::iterator<std::forward_iterator_tag, const node_t, std::ptrdiff_t, const node_t*, const node_t&>

    {
    private:
        const path_iterable* _parent;
        const node_t* _data;
        
        const_iterator(const path_iterable* parent, const node_t* data) : _parent{parent}, _data{data} {}
    public:
        const_iterator() : const_iterator{nullptr, nullptr} {}
        const_iterator(const const_iterator& o) : _parent{o._parent}, _data{o._data} {}

        void swap(const_iterator& o) noexcept
        {
            using std::swap;
            swap(o._data, o._data);
            swap(o._parent, o._parent);
        }

        const_iterator& operator++ ()
        {
            if (*(_data) == _parent->_start)
                _data = nullptr;
            else
                _data = &_parent->_acc(*_data);
            return *this;
        }

        const_iterator operator++ (int)
        {
            const_iterator tmp(*this);
            if (*(_data) == _parent->_start)
                _data = nullptr;
            else
                _data = &_parent->_acc(*_data);
            return tmp;
        }

        bool operator== (const const_iterator& rhs) const
        {
            return _data == rhs._data && _parent == rhs._parent;
        }

        bool operator!= (const const_iterator& rhs) const
        {
            return _data != rhs._data || _parent != rhs._parent;
        }

        const node_t& operator* () const
        {
            return *(_data);
        }

        const node_t& operator-> () const
        {
            return *(_data);
        }
    };

    const_iterator begin() const { return const_iterator(this, &_cur); }
    const_iterator end() const { return const_iterator{this, nullptr}; }

};

template <typename Access>
path_iterable<Access> make_path_iterable(Access acc, node_t cur_pos, node_t start_pos) 
{
    return {acc, cur_pos, start_pos};
}


std::vector<std::string> read_input(const std::string& name)
{
    std::vector<std::string> space;

    std::ifstream in{name};

    std::string line;

    while (std::getline(in, line))
    {
        space.push_back(std::move(line));
    }

    return space;
}


template <typename OuterIterator, typename Pred, typename InnerIterator = typename OuterIterator::value_type::const_iterator>
std::pair<OuterIterator, InnerIterator> find2d_if(OuterIterator begin, OuterIterator end, Pred pred) 
{
    for (auto it = begin; it != end; ++it)
    {
        auto it2 = std::find_if(it->cbegin(), it->cend(), pred);

        if (it2 != it->cend())
            return {it, it2};
    }

    return {end, {}};
}


template <typename Node, typename GetNeighbors, typename GetDistance, typename Prev, typename Dist>
void dijstras(Node start, Prev prev, Dist dist, GetNeighbors get_neighbors, GetDistance get_distance)
{
    using distance = decltype(get_distance(std::declval<Node>(), std::declval<Node>()));
    using record = std::pair<Node, distance>;

    auto cmp = [](const record& p1, const record& p2){ return !(std::get<1>(p1) < std::get<1>(p2)); };

    std::priority_queue<record, std::vector<record>, decltype(cmp)> queue(cmp);

    queue.emplace(start, 0);

    while (!queue.empty())
    {
        auto cur = queue.top(); queue.pop();

        const auto& cur_node = std::get<0>(cur);
        const auto& cur_dist = std::get<1>(cur);

        for (const auto& neighbor : get_neighbors(cur_node))
        {
            auto alt_dist = cur_dist + get_distance(cur_node, neighbor);

            if (alt_dist < dist(neighbor))
            {
                dist(neighbor) = alt_dist;
                prev(neighbor) = cur_node;
                queue.emplace(neighbor, alt_dist);
            }
        }
    }
}


int main(int argc, char* argv[])
{

    if (argc == 1) 
    {
        std::cout << "No input file given\n";
        return EXIT_FAILURE;
    }

    auto space = read_input(argv[1]);

    auto height = space.size();
    auto width = space[0].size();

    auto start = find2d_if(space.cbegin(), space.cend(), [](char c){ return c == 'S'; });
    auto end = find2d_if(space.cbegin(), space.cend(), [](char c){ return c == 'E'; });

    if (start.first == space.cend() || end.first == space.cend())
    {
        std::cout << "Input does not contain start and end nodes\n";
        return EXIT_FAILURE;
    }

    auto start_y = std::distance(space.cbegin(), start.first);
    auto start_x = std::distance(start.first->cbegin(), start.second);
    auto start_pos = node_t{false, start_y, start_x};

    auto end_y = std::distance(space.cbegin(), end.first);
    auto end_x = std::distance(end.first->cbegin(), end.second);
    auto end_pos = node_t{false, end_y, end_x};

    auto get_neighbors = [&space, height, width](const node_t& node)
    {

        auto z = std::get<0>(node);
        auto i = std::get<1>(node);
        auto j = std::get<2>(node);

        std::vector<node_t> neighbors {node_t{z,i,j+1}, node_t{z,i,j-1}, node_t{z,i+1, j}, node_t{z, i-1, j}};
        neighbors.erase(std::remove_if(neighbors.begin(), neighbors.end(), [&space, width, height](const node_t& node)
                    {
                    return !(std::get<1>(node) < height && 
                            std::get<2>(node) < width &&
                            space[std::get<1>(node)][std::get<2>(node)] != 'X');
                    }), neighbors.end());

        if (space[i][j] == 'W') 
            neighbors.emplace_back(!z, i, j);

        return neighbors;
    };

    auto get_distance = [&space](const node_t& node1, const node_t& node2) -> std::size_t
    {
        auto z1 = std::get<0>(node1);
        auto z2 = std::get<0>(node2);

        if (z1 == false && z2 == false) return 2;

        return 1;
    };

    std::vector<std::size_t> dists(2 * height * width, std::numeric_limits<std::size_t>::max());
    std::vector<node_t> prevs(2 * height * width, node_t{});

    auto prev = [&prevs, height, width](const node_t& node) -> node_t&
    { 
        return prevs[std::get<0>(node)*(height*width) + std::get<1>(node)*width + std::get<2>(node)]; 
    };

    auto dist = [&dists, height, width](const node_t& node) -> std::size_t&
    {
        return dists[std::get<0>(node)*(height*width) + std::get<1>(node)*width + std::get<2>(node)]; 
    };

    dijstras(start_pos, prev, dist, get_neighbors, get_distance);

    std::string directions;

    auto to_direction = [](const node_t& node1, const node_t& node2)
    {
        if (std::get<0>(node1) != std::get<0>(node2))
        {
            return 'W';
        }
        else if (std::get<1>(node1) < std::get<1>(node2))
        {
            return 'D';
        }
        else if (std::get<1>(node1) > std::get<1>(node2))
        {
            return 'U';
        }
        else if (std::get<2>(node1) < std::get<2>(node2))
        {
            return 'R';
        }
        else
        {
            return 'L';
        }
    };

    auto path_iterable = make_path_iterable(prev, end_pos, start_pos);

    std::transform(std::next(path_iterable.begin()), path_iterable.end(), path_iterable.begin(), std::back_inserter(directions), to_direction);

    std::reverse(directions.begin(), directions.end());

    std::cout << dist(end_pos) << ' ';

    for (auto d : directions)
    {
        std::cout << d;
    }

    std::cout << '\n';

    return EXIT_SUCCESS;
}

