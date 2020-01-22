#pragma once

/* This file provides adaptors for objects supporting the range-for
   syntax. Basically poor man's ranges.
   */

#include <algorithm>
#include <utility>

namespace custom
{

namespace details
{

template <template <class It, class Fun> class IteratorPolicy, class View, class Fun>
struct view_adaptor
{
    view_adaptor(View& view, Fun fun)
        : view_(view)
        , fun_(fun)
    {
    }

    auto begin()
    {
        return IteratorPolicy{view_.begin(), view_.end(), fun_};
    }

    auto end()
    {
        return IteratorPolicy{view_.end(), view_.end(), fun_};
    }

    View& view_;
    Fun fun_;
};

/* CRTP Hack to avoid defining the same comparison operator.
   */

template <class Self>
struct default_not_equal
{
    decltype(auto) operator!= (default_not_equal const & rhs) const
    {
        return static_cast<const Self*>(this)->it_ != static_cast<const Self*>(&rhs)->it_;
    }
};


/* This policy provides the map operation on ranges.
   Not useful in our example due to the stack holding 
   objects of the same type but useful if we stored variants.
   */

template <class It, class Fun>
struct map_policy : default_not_equal<map_policy<It, Fun>>
{
    map_policy(It begin, It end, Fun& fun)
        : it_(begin)
        , end_(end)
        , fun_(fun)
    {
    }

    map_policy& operator++()
    {
        ++it_; 
        return *this;
    }

    decltype(auto) operator*()
    {
        return fun_(*it_);
    }

    It it_;
    It end_;
    Fun& fun_;
};

/* This policy provides the filter policy on ranges.
   Basically the only operation useful in our garbage collection example.
   */

template <class It, class Fun>
struct filter_policy : default_not_equal<filter_policy<It, Fun>>
{
    filter_policy(It begin, It end, Fun& fun)
        : it_(begin)
        , end_(end)
        , fun_(fun)
    {
        find_next();
    }

    filter_policy& operator++()
    {
        ++it_;
        find_next();
        return *this;
    }


    void find_next()
    {
        while (it_ != end_)
        {
            if (fun_(*it_))
            {
                return;
            }

            ++it_;
        }
    }

    decltype(auto) operator*()
    {
        return *it_;
    }

    It it_;
    It end_;
    Fun& fun_;
};

}

template <class View, class Fun>
using map_view_adaptor = details::view_adaptor<details::map_policy, View, Fun>;

template <class View, class Fun>
using filter_view_adaptor = details::view_adaptor<details::filter_policy, View, Fun>;

template <template <class, class> class Adaptor, class View, class Fun>
Adaptor<View, Fun> make_view_adaptor(View& view, Fun fun)
{
    return {view, fun};
}

} // custom
