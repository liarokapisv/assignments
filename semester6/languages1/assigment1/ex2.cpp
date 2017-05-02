#include <tuple>
#include <queue>
#include <algorithm>
#include <vector>
#include <iostream>
#include <utility>
#include <string>
#include <iterator>
#include <fstream>


std::vector<std::string> read_input(std::string name)
{
    std::ifstream in{name};

    std::vector<std::string> space;
    
    std::string line;

    std::size_t n;
    in >> n;
    
    std::getline(in, line);

    for (std::size_t i = 0; i != n; ++i)
    {
        std::getline(in, line);
        space.push_back(std::move(line));
    }

    return space;
}

template <typename Distance, typename Node>
using path_info = std::pair<Distance, std::vector<Node>>;

template <typename Distance, typename Node, typename GetNeighbors, typename GetDistance, typename Visit, typename HasVisited>
path_info<Distance, Node> bfs_shortest_path(Distance weight_limit, Node start, Node target, Visit visit, HasVisited has_visited, GetNeighbors get_neighbors, GetDistance get_distance)
{
    std::vector<std::queue<std::pair<Node, path_info<Distance, Node>>>> to_visit_neighbors(weight_limit+1);

    to_visit_neighbors[0].push({start, {0, {start}}});

    while (std::any_of(to_visit_neighbors.begin(), to_visit_neighbors.end(), 
                [](const std::queue<std::pair<Node, path_info<Distance, Node>>>& q) { return !q.empty(); }))
    {
        auto& cur_visit = to_visit_neighbors[0];
        
        while (!cur_visit.empty())
        {
            auto cur_node = cur_visit.front(); cur_visit.pop();

            if (!has_visited(cur_node.first))
                visit(cur_node.first) = cur_node.second;
            else
                continue;

            if (cur_node.first == target) break;

            for (const auto& neighbor : get_neighbors(cur_node.first))
            {
                if (!has_visited(neighbor))
                {
                    auto cur_path = visit(cur_node.first);
                    cur_path.second.push_back(neighbor);
                    
                    auto distance = get_distance(cur_node.first, neighbor);

                    to_visit_neighbors[distance].push({neighbor, {cur_path.first + distance, cur_path.second}});
                }
                
            }
        }

        std::rotate(to_visit_neighbors.begin(), to_visit_neighbors.begin()+1, to_visit_neighbors.end());
    }

    return visit(target);
} 
        
using node_t = std::tuple<bool,std::size_t, std::size_t>;
    
int main(int argc, char* argv[])
{
    
    auto space = read_input(argv[1]);

    auto height = space.size();
    auto width = space[0].size();
    
    node_t start_pos, end_pos;

    for (std::size_t i = 0; i != space.size(); ++i)
    {
        for (std::size_t j = 0; j != space[i].size(); ++j)
        {
            if (space[i][j] == 'S')
            {
                start_pos = node_t{false, i,j};
            }
  
            if (space[i][j] == 'E')
            {
                end_pos = node_t{false, i,j};
            }
        }
    }

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

    std::vector<path_info<std::size_t, node_t>> paths(2*height*width, {static_cast<std::size_t>(-1), {}});
    
    auto visit = [&paths, height, width](const node_t& node) -> path_info<std::size_t, node_t>&
    {
        return paths[std::get<0>(node)*(height*width) + std::get<1>(node)*width + std::get<2>(node)]; 
    };

    auto has_visited = [&visit](const node_t& node)
    {
        return visit(node).first != static_cast<std::size_t>(-1);
    };

    auto result = bfs_shortest_path(2, start_pos, end_pos, visit, has_visited, get_neighbors, get_distance);
    auto shortest_path = result.second;
    auto shortest_distance = result.first;

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

    std::transform(shortest_path.begin(), std::prev(shortest_path.end()), std::next(shortest_path.begin()), std::back_inserter(directions), to_direction);

    std::cout << shortest_distance << ' ';

    for (auto d : directions)
    {
        std::cout << d;
    }

    std::cout << '\n';

    return 0;
}




  


        

