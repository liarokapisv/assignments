
#include <tuple>
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


/* Very fragile class used to model immutable list references. */

template <typename T>
class immutable_list : protected std::shared_ptr<std::pair<const T, immutable_list<T>>> 
{
    private:
        using value_type = std::pair<const T, immutable_list>;
        using base = std::shared_ptr<value_type>;
        using base::shared_ptr;

    public:
        immutable_list() = default;
        immutable_list(const immutable_list&) = default;
        immutable_list(immutable_list&&) = default;
        immutable_list& operator=(const immutable_list&) = default;
        immutable_list& operator=(immutable_list&&) = default;

        immutable_list(const T& data) : immutable_list{data, nullptr} {}
        immutable_list(const T& data, const immutable_list& list) : immutable_list{std::make_shared<value_type>(data, list)} {}

        /* We don't want to use the default destructor because it would start a chain
         *      * of recursive destructor calls for lists whose nodes are only referenced
         *           * by their parents which could potentially lead to a stack overflow for long lists 
         *                */

        ~immutable_list()
        {
            while (!this->empty() && this->use_count() < 2)
            {
                *this = std::move(this->get()->second);
            }
        }

        bool empty() const { return *this == nullptr; }

        const T& head() const { return this->get()->first; }

        const immutable_list& tail() const { return this->get()->second; }


        class const_iterator : public std::iterator<std::forward_iterator_tag, const T,
        std::ptrdiff_t, const T*, const T&>
    {
        private:
            value_type* itr;

        public:
            const_iterator() : itr{nullptr} {}

            explicit const_iterator(value_type* o) : itr{o} {}

            void swap(const_iterator& o) noexcept
            {
                using std::swap;
                swap(itr, o.itr);
            }

            const_iterator& operator++ ()
            {
                itr = (itr->second).get();
                return *this;
            }

            const_iterator operator++ (int)
            {
                const_iterator tmp(*this);
                itr = (itr->second).get();
                return tmp;
            }

            bool operator== (const const_iterator& rhs) const
            {
                return itr == rhs.itr;
            }

            bool operator!= (const const_iterator& rhs) const
            {
                return itr != rhs.itr;
            }

            const T& operator* () const
            {
                return itr->first;
            }

            const T& operator-> () const
            {
                return itr->first;
            }
    };

        const_iterator cbegin() const { return const_iterator{this->get()}; }
        const_iterator cend() const { return {}; }
};

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

template <typename Distance, typename Node>
using path_info = std::pair<Distance, immutable_list<Node>>; 

using node_t = std::tuple<bool, std::size_t, std::size_t>;

/* Invariant: At the i-th iteration, filtering the unvisited nodes of to_visit_neigbors[0]
 *  * gives you all best paths from start of length i-1. Below is a proof by induction for the case of weight_limit = 2. The proof can
 *   * be further generalized for any weight_limit.
 *    *
 *     * First some definitions:
 *      * - The tail of a path is the path that results if we remove the last node from the original path.
 *       * - A 1-diff path is a path whose tail's total distance differs by 1.
 *        * - A 2-diff path is a path whose tail's total distance differs by 2.
 *         *
 *          * Proof:
 *           * 0th-iteration: True since there are no paths of length -1.
 *            * 1st-iteration: Obviously true, to_visit_neighbors[0] only contains the starting node.
 *             * kth-iteration: Any best path is either 1-diff or 2-diff with a best path for a tail. 
 *              *                At the (k-2)th-iteration to_visit_neighbors[2] will contain all 2-diff best paths of length (k-1)
 *               *                and at the (k-1)th-iteration to_visit_neighbors[1] will contain all 1-diff best paths of length (k-1)
 *                *                After the rotations, at the kth-iteration, to_visit_neighbors[0] will contain all of the above which
 *                 *                constitute all of the best paths of length (k-1).
 *                  */

    template <typename Distance, typename Node, typename GetNeighbors, typename GetDistance, typename Visit, typename HasVisited>
path_info<Distance, Node> bfs_shortest_path(Distance weight_limit, Node start, Node target, Visit visit, HasVisited has_visited, GetNeighbors get_neighbors, GetDistance get_distance)
{
    std::vector<std::vector<std::pair<Node, path_info<Distance, Node>>>> to_visit_neighbors(weight_limit+1);

    to_visit_neighbors[0].push_back({start, {0, {start}}});

    while (std::any_of(to_visit_neighbors.begin(), to_visit_neighbors.end(), 
                [](const std::vector<std::pair<Node, path_info<Distance, Node>>>& q) { return !q.empty(); }))
    {
        auto& cur_visit = to_visit_neighbors[0];

        while (!cur_visit.empty())
        {
            auto cur_info = cur_visit.back(); cur_visit.pop_back();

            const auto& cur_node = cur_info.first;

            if (!has_visited(cur_node))
            {
                const auto& cur_best_path_info = cur_info.second;

                if (cur_node == target)
                    return cur_best_path_info;

                visit(cur_node) = cur_best_path_info;


                for (const auto& neighbor : get_neighbors(cur_node))
                {
                    if (!has_visited(neighbor))
                    {
                        auto distance = get_distance(cur_node, neighbor);
                        const auto& cur_best_distance = cur_best_path_info.first;
                        const auto& cur_best_path = cur_best_path_info.second;
                        to_visit_neighbors[distance].push_back({neighbor, {cur_best_distance + distance, {neighbor, cur_best_path}}});
                    }

                }
            }
        }

        std::rotate(to_visit_neighbors.begin(), std::next(to_visit_neighbors.begin()), to_visit_neighbors.end());
    }

    return visit(target);
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

    auto get_distance = [&space](const node_t& node1, const node_t& node2)
    {
        auto z1 = std::get<0>(node1);
        auto z2 = std::get<0>(node2);

        if (z1 == false && z2 == false) return 2;

        return 1;
    };

    std::vector<path_info<std::size_t, node_t>> paths(2*height*width, 
            {std::numeric_limits<std::size_t>::max(), {}});

    auto visit = [&paths, height, width](const node_t& node) -> path_info<std::size_t, node_t>&
    {
        return paths[std::get<0>(node)*(height*width) + std::get<1>(node)*width + std::get<2>(node)]; 
    };

    auto has_visited = [&visit](const node_t& node)
    {
        return visit(node).first != std::numeric_limits<std::size_t>::max();
    };

    auto result = bfs_shortest_path(static_cast<std::size_t>(2), start_pos, end_pos, visit, has_visited, get_neighbors, get_distance);
    auto& shortest_distance = result.first;
    auto& shortest_path = result.second;

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

    std::transform(std::next(shortest_path.cbegin()), shortest_path.cend(), shortest_path.cbegin(), std::back_inserter(directions), to_direction);

    std::reverse(directions.begin(), directions.end());

    std::cout << shortest_distance << ' ';

    for (auto d : directions)
    {
        std::cout << d;
    }

    std::cout << '\n';

    return EXIT_SUCCESS;
}

