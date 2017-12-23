
#include <tuple>
#include <queue>
#include <algorithm>
#include <vector>
#include <iostream>
#include <utility>
#include <string>
#include <iterator>
#include <fstream>


/* Class that provides iterator access to a sequence obtained 
 * by iterating a functor.
 */

template <class Func, class Arg>
class iterable_range
{
private:
    Func _acc;
    Arg _cur;
    Arg _target;

public:
    template <class F, class A>
    iterable_range(F&& acc, A&& cur, A&& target) : 
        _acc{std::forward<F>(acc)}, _cur{std::forward<A>(cur)} , _target{std::forward<A>(target)} {}

    class const_iterator : public std::iterator<std::forward_iterator_tag, const Arg, std::ptrdiff_t, const Arg*, const Arg&>

    {
        friend iterable_range;

    private:
        const iterable_range* _parent;
        const Arg* _data;
        
        const_iterator(const iterable_range* parent, const Arg* data) : _parent{parent}, _data{data} {}

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
            if (*(_data) == _parent->_target)
                _data = nullptr;
            else
                _data = &_parent->_acc(*_data);
            return *this;
        }

        const_iterator operator++ (int)
        {
            const_iterator tmp(*this);
            if (*(_data) == _parent->_target)
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

        const Arg& operator* () const
        {
            return *(_data);
        }

        const Arg& operator-> () const
        {
            return *(_data);
        }
    };

    const_iterator begin() const { return const_iterator(this, &_cur); }
    const_iterator end() const { return const_iterator{this, nullptr}; }

};

template <class Access, class Arg>
auto make_iterable_range(Access&& acc, Arg&& target_pos, Arg&& start_pos) -> iterable_range<class std::decay<Access>::type, class std::decay<Arg>::type>
{
    return {std::forward<Access>(acc), std::forward<Arg>(target_pos), std::forward<Arg>(start_pos)};
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


template <class OuterIterator, class Pred, class InnerIterator = class OuterIterator::value_type::const_iterator>
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


template <class Node, class GetNeighbors, class GetDistance, class Prev, class Dist, class Distance = decltype(std::declval<GetDistance>()(std::declval<Node>(),std::declval<Node>()))>
void weight_limited_dijstra(Distance maxWeight, Node start, Prev prev, Dist dist, GetNeighbors get_neighbors, GetDistance get_distance)
{
    using record = std::pair<Node, Distance>;

    std::vector<std::vector<record>> queue (maxWeight+1);

    queue[0].emplace_back(start, dist(start));

    while (std::any_of(queue.begin(), queue.end(), [](const std::vector<record>& v){ return !v.empty(); })) 
    {
        while (!queue[0].empty()) 
        {
            auto cur = queue[0].back(); queue[0].pop_back();

            const auto& cur_node = std::get<0>(cur);
            const auto& cur_dist = std::get<1>(cur);

            for (const auto& neighbor : get_neighbors(cur_node))
            {
                auto weight = get_distance(cur_node, neighbor);
                auto alt_dist = cur_dist + weight;

                if (alt_dist < dist(neighbor))
                {
                    dist(neighbor) = alt_dist;
                    prev(neighbor) = cur_node;
                    queue[weight].emplace_back(neighbor, alt_dist);
                }
            }
        }

        std::rotate(queue.begin(), std::next(queue.begin()), queue.end());
    }
}


int main(int argc, char* argv[])
{

    using node_t = std::tuple<bool, std::size_t, std::size_t>;

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

    dist(start_pos) = 0;
    weight_limited_dijstra(2, start_pos, prev, dist, get_neighbors, get_distance);

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

    auto path_range = make_iterable_range(prev, end_pos, start_pos);

    std::transform(std::next(path_range.begin()), path_range.end(), path_range.begin(), std::back_inserter(directions), to_direction);

    std::reverse(directions.begin(), directions.end());

    std::cout << dist(end_pos) << ' ';

    for (auto d : directions)
    {
        std::cout << d;
    }

    std::cout << '\n';

    return EXIT_SUCCESS;
}

