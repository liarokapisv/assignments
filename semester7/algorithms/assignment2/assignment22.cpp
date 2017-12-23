#include <vector>
#include <algorithm>
#include <iostream>
#include <utility>
#include <queue>
#include <iterator>
#include <set>
#include <unordered_map>

namespace assignment22 {

    using id_t = std::size_t;
    using pos_t = double;
    using point_t = std::pair<pos_t, pos_t>;
    using seg_t = std::pair<point_t, point_t>;
    using points_t = std::vector<point_t>;

    enum class event { left_endpoint, crossing_point, right_endpoint };

    pos_t direction(point_t pi, point_t pj, point_t pk)
    {
        auto x0 = pi.first;
        auto y0 = pi.second;
        auto x1 = pk.first;
        auto y1 = pk.second;
        auto x2 = pj.first;
        auto y2 = pj.second;

        return (x1 - x0)*(y2 - y0) - (x2 - x0)*(y1 - y0);
    }

    bool on_segment(point_t pi, point_t pj, point_t pk)
    {
        auto xi = pi.first;
        auto yi = pi.second;
        auto xj = pj.first;
        auto yj = pj.second;
        auto xk = pk.first;
        auto yk = pk.second;

        if (std::min(xi, xj) <= xk && xk <= std::max(xi, xj) &&
                std::min(yi, yj) <= yk && yk <= std::max(yi, yj))
            return true;

        return false;
    }

    bool segments_intersect(seg_t seg1, seg_t seg2)
    {
        auto p1 = seg1.first;
        auto p2 = seg1.second;
        auto p3 = seg2.first;
        auto p4 = seg2.second;

        auto d1 = direction(p3, p4, p1);
        auto d2 = direction(p3, p4, p2);
        auto d3 = direction(p1, p2, p3);
        auto d4 = direction(p1, p2, p4);

        if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
                ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)))
            return true;
        if (std::fabs(d1) < 0.001 && on_segment(p3, p4, p1))
            return true;
        if (std::fabs(d2) < 0.001 && on_segment(p3, p4, p2))
            return true;
        if (std::fabs(d3) < 0.001 && on_segment(p1, p2, p3))
            return true;
        if (std::fabs(d4) < 0.001 && on_segment(p1, p2, p4))
            return true;

        return false;
    }

    point_t intersection_of(seg_t seg1, seg_t seg2)
    {
        auto pl1 = seg1.first;
        auto pr1 = seg1.second;

        auto m1 = (pl1.second - pr1.second) / (pl1.first - pr1.first);
        auto c1 = (pl1.second - m1*pl1.first);

        auto pl2 = seg2.first;
        auto pr2 = seg2.second;

        auto m2 = (pl2.second - pr2.second) / (pl2.first - pr2.first);
        auto c2 = (pl2.second - m2*pl2.first);


        auto intersection_x = (c2-c1) / (m1 - m2);
        auto intersection_y = m1*intersection_x + c1;

        return {intersection_x, intersection_y};
    }

    pos_t y_at_x(seg_t seg1, pos_t x)
    {
        // y = m*x + c
        auto pl1 = seg1.first;
        auto pr1 = seg1.second;

        auto m1 = (pl1.second - pr1.second) / (pl1.first - pr1.first);
        auto c1 = (pl1.second - m1*pl1.first);

        return m1*x + c1;
    }

    struct pairhash {
        public:
                std::size_t operator()(const point_t& p) const
                {
                    return std::hash<pos_t>()(p.first) ^ std::hash<pos_t>()(p.second);
                }
    };

    std::vector<std::pair<seg_t, seg_t>> bentley_ottman(points_t& points)
    {
        using point_info = std::pair<point_t, event>;

        std::unordered_map<point_t, seg_t, pairhash> endpoint_to_segment;
        std::unordered_map<point_t, std::pair<seg_t, seg_t>, pairhash> crossing_to_segments;

        auto q_comparator = [](point_info p1, point_info p2)
        {
            auto x1 = p1.first.first;
            auto x2 = p2.first.first;

            return (x1 < x2);
        };

        std::multiset<point_info, decltype(q_comparator)> q(q_comparator);

        for (id_t i = 0; i != points.size(); ++i)
        {
            if (i % 2 == 0)
            {
                q.emplace(points[i], event::left_endpoint);
                endpoint_to_segment.emplace(points[i], std::make_pair(points[i], points[i+1]));
            }
            else
            {
                q.emplace(points[i], event::right_endpoint);
                endpoint_to_segment.emplace(points[i], std::make_pair(points[i-1], points[i]));
            }
        }

        pos_t sweep_line = 0;

        auto t_comparator = [&sweep_line](seg_t seg1, seg_t seg2)
        {
            return y_at_x(seg1, sweep_line) < y_at_x(seg2, sweep_line);
        };

        std::multiset<seg_t, decltype(t_comparator)> t(t_comparator);

        std::vector<std::pair<seg_t, seg_t>> result;

        while (!q.empty())
        {
            auto point_info = *q.begin();
            q.erase(q.begin());

            auto event_type = point_info.second;
            auto point = point_info.first;

            sweep_line = point.first;

            if (event_type == event::left_endpoint)
            {
                auto seg = endpoint_to_segment[point];
                t.insert(seg);
                auto it1 = t.lower_bound(seg);
                auto it2 = t.upper_bound(seg);
                if (it1 != t.begin() && it2 != t.end())
                {
                    auto seg1 = *std::prev(it1);
                    auto seg2 = *it2;
                    if (segments_intersect(seg1, seg2))
                    {
                        auto intersection = intersection_of(seg1, seg2);
                        q.emplace(intersection, event::crossing_point);
                        crossing_to_segments.emplace(intersection, std::make_pair(seg1, seg2));
                    }
                }

                if (it1 != t.begin())
                {
                    auto seg1 = *std::prev(it1);
                    if (segments_intersect(seg, seg1))
                    {
                        auto intersection = intersection_of(seg, seg1);
                        q.emplace(intersection, event::crossing_point);
                        crossing_to_segments.emplace(intersection, std::make_pair(seg, seg1));
                    }
                }

                if (it2 != t.end())
                {
                    auto seg2 = *it2;
                    if (segments_intersect(seg, seg2))
                    {
                        auto intersection = intersection_of(seg, seg2);
                        q.emplace(intersection, event::crossing_point);
                        crossing_to_segments.emplace(intersection, std::make_pair(seg, seg2));
                    }
                }

            }
            else if (event_type == event::right_endpoint)
            {
                auto seg = endpoint_to_segment[point];
                auto it1 = t.lower_bound(seg);
                auto it2 = t.upper_bound(seg);
                if (it1 != t.begin() && it2 != t.end())
                {
                    auto seg1 = *std::prev(it1);
                    auto seg2 = *it2;
                    if (segments_intersect(seg1, seg2))
                    {
                        auto intersection = intersection_of(seg, seg2);
                        q.emplace(intersection, event::crossing_point);
                        crossing_to_segments.emplace(intersection, std::make_pair(seg, seg2));
                    }
                }

                t.erase(seg);
            }
            else if (event_type == event::crossing_point)
            {
                auto segments = crossing_to_segments[point];
                auto seg1 = segments.first;

                result.push_back(segments);

                auto it_p = t.equal_range(seg1);
                auto s = *it_p.first;
                auto tt = s;
                if (it_p.first != t.end()) 
                    tt = *std::next(it_p.first);
                if (std::distance(std::next(it_p.first,2), t.end()) < 0)
                    t.erase(it_p.first, t.end());
                else
                    t.erase(it_p.first,std::next(it_p.first,2));
                t.insert(s);
                t.insert(tt);
                it_p = t.equal_range(seg1);

                if (it_p.first != t.begin())
                {
                    auto r = *std::prev(it_p.first);
                    q.erase(std::make_pair(intersection_of(s, r), event::crossing_point));
                    if (segments_intersect(r, tt))
                    {
                        auto intersection = intersection_of(r, tt);
                        crossing_to_segments.emplace(intersection, std::make_pair(r, tt));
                        q.emplace(intersection, event::crossing_point);
                    }
                }

                if (it_p.second != t.end())
                {
                    auto u = *it_p.second;
                    q.erase(std::make_pair(intersection_of(tt, u), event::crossing_point));
                    if (segments_intersect(s, u))
                    {
                        auto intersection = intersection_of(s, u);
                        crossing_to_segments.emplace(intersection, std::make_pair(s, u));
                        q.emplace(intersection, event::crossing_point);
                    }
                }

            }


        }

        return result; 


    }



} // namespace assignment22


int main()
{
    namespace as = assignment22;

    std::vector<as::point_t> points = {{0,0}, {1, 1},
                                       {1.1,1}, {2.1, 0},
                                       {1.2,0}, {2.2,1},
                                       {1.3,1}, {2.3,0}};

    auto ret = as::bentley_ottman(points);

    for (auto& r : ret)
        std::cout << "seg1: (" << r.first.first.first << ',' << r.first.first.second << ")-(" << r.first.second.first << ',' << r.second.second.second << "), seg2: (" 
                               << r.second.first.first << ',' << r.second.first.second<< ")-(" << r.second.second.first << ',' << r.second.second.second << ")\n";
    return 0;
}

