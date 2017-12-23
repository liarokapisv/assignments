#include <iostream>  
#include <vector>  
#include <tuple>  
#include <algorithm>  
#include <cstdint>  
#include <numeric>  
#include <limits>

using sid_t = uint_fast64_t;
using pos_t = uint_fast64_t;

template <class Getter>  
std::vector<pos_t> total_distances(std::vector<std::tuple<sid_t, pos_t, pos_t>>& data, Getter getter)   
{  
    std::sort(data.begin(), data.end(),   
            [getter](const std::tuple<sid_t, pos_t, pos_t>& l, const std::tuple<sid_t, pos_t, pos_t>& r)   
            { return getter(l) < getter(r); });  

    std::vector<pos_t> result(data.size());  

    const auto reference = data[0];  
    const auto ref_id = std::get<0>(reference);  
    const auto ref_val = getter(reference);  
    const pos_t ref_total = std::accumulate(data.begin()+1, data.end(), pos_t{0},   
            [getter,ref_val](const pos_t& d, const std::tuple<sid_t, pos_t, pos_t>& t){ return d + (getter(t) - ref_val); });  
    result[ref_id] = ref_total;  

    auto prev_id = ref_id;  
    auto prev_val = ref_val;  

    for (sid_t i = 1; i != data.size(); ++i)  
    {  
        const auto student = data[i];  
        const auto student_id = std::get<0>(student);  
        const auto student_val = getter(student);  

        const auto diff = student_val - prev_val;  
        result[student_id] = result[prev_id] + (2*i-data.size())*diff;  
        prev_id = student_id;  
        prev_val = student_val;  
    }  


    return result;  
}  

int main()  
{  
    std::ios::sync_with_stdio(false);  

    sid_t n;  
    std::cin >> n;  

    std::vector<std::tuple<sid_t, pos_t, pos_t>> students;  

    for (sid_t i = 0; i != n; ++i)  
    {  
        pos_t x, y;  
        std::cin >> x >> y;  
        students.emplace_back(i, x, y);  
    }  

    const auto x_dists = total_distances(students,  
            [](const std::tuple<sid_t, pos_t, pos_t>& s)  
            { return std::get<1>(s); });  

    const auto y_dists = total_distances(students,  
            [](const std::tuple<sid_t, pos_t, pos_t>& s)  
            { return std::get<2>(s); });    

    pos_t min_dist = std::numeric_limits<pos_t>::max();

    for (sid_t i = 0; i != n; ++i)  
    {  
        if (x_dists[i] + y_dists[i] < min_dist)  
        {  
            min_dist = x_dists[i] + y_dists[i];  
        }  
    }  

    std::cout << min_dist << std::endl;  

    return 0;  

}  

