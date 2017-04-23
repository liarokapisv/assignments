#include <tuple>
#include <queue>
#include <algorithm>
#include <vector>
#include <iostream>
#include <utility>
#include <unordered_map>
#include <string>


std::vector<std::string> read_input()
{
    std::vector<std::string> space;
    
    std::string line;

    while (std::getline(std::cin, line))
    {
        space.push_back(line);
    }

    return space;
}

struct tuple_hash
{
    std::size_t operator()(const std::tuple<bool, int, int> &t) const
    {
        return std::hash<bool>{}(std::get<0>(t)) ^
               std::hash<int>{}(std::get<1>(t)) ^
               std::hash<int>{}(std::get<2>(t));
    }
};

template <typename Node, typename GetNeighbors, typename GetDistance>
std::vector<Node> bfs_shortest_path(int weight_limit, Node start, Node target, GetNeighbors get_neighbors, GetDistance get_distance)
{
    std::unordered_map<Node, std::vector<Node>, tuple_hash> visited;

    std::vector<std::queue<std::pair<Node, std::vector<Node>>>> to_visit_neighbors(weight_limit+1);

    to_visit_neighbors[0].push({start, {start}});

    while (std::any_of(to_visit_neighbors.begin(), to_visit_neighbors.end(), [](const std::queue<std::pair<Node, std::vector<Node>>>& q) { return !q.empty(); }))
    {
        auto& cur_visit = to_visit_neighbors[0];
        
        while (!cur_visit.empty())
        {
            auto cur_node = cur_visit.front(); cur_visit.pop();


            if (visited.find(cur_node.first) == visited.end())
                visited[cur_node.first] = cur_node.second;
            else
                continue;

            if (cur_node.first == target) break;

            for (const auto& neighbor : get_neighbors(cur_node.first))
            {
                if (visited.find(neighbor) == visited.end())
                {
                    auto cur_path = visited[cur_node.first];
                    cur_path.push_back(neighbor);
                    
                    auto distance = get_distance(cur_node.first, neighbor);
                    to_visit_neighbors[distance].push({neighbor, cur_path});
                }
            }
        }

        std::rotate(to_visit_neighbors.begin(), to_visit_neighbors.begin()+1, to_visit_neighbors.end());
    }

    return visited[target];
} 
        
    
int main()
{
    using node_t = std::tuple<bool,int,int>;
    
    auto space = read_input();

    node_t start_pos, end_pos;


    for (int i = 0; i < space.size(); ++i)
    {
        for (int j = 0; j < space[i].size(); ++j)
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

    auto get_neighbors = [&space](const node_t& node)
    {
        using node_t = std::tuple<bool,int,int>;

        auto height = space.size();
        auto width = space[0].size();

        auto z = std::get<0>(node);
        auto i = std::get<1>(node);
        auto j = std::get<2>(node);

        std::vector<node_t> neighbors {node_t{z,i,j+1}, node_t{z,i,j-1}, node_t{z,i+1, j}, node_t{z, i-1, j}};
        neighbors.erase(std::remove_if(neighbors.begin(), neighbors.end(), [&space, width, height](const node_t& node)
        {
            return !(std::get<1>(node) >= 0 && std::get<1>(node) < height && 
                   std::get<2>(node) >= 0 && std::get<2>(node) < width &&
                   space[std::get<1>(node)][std::get<2>(node)] != 'X');
        }), neighbors.end());

        if (space[i][j] == 'W') 
            neighbors.push_back(node_t{!z, i, j});

        return neighbors;
    };

    auto get_distance = [&space](const node_t& node1, const node_t& node2)
    {
        auto z1 = std::get<0>(node1);
        auto z2 = std::get<0>(node2);

        if (z1 == false && z2 == false) return 2;

        return 1;
    };

    auto shortest_path = bfs_shortest_path(2, start_pos, end_pos, get_neighbors, get_distance);

    for (auto& node : shortest_path)
    {
        std::cout << std::get<0>(node) << " " << std::get<1>(node) << " " << std::get<2>(node) << "\n";
    }

    return 0;
}




  


        

