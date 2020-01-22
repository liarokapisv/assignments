#pragma once

/* A heap that provides an automatic mark and sweep 
   garbage collection scheme for objects of the specified type.
   This is pretty low level, it needs to be provided with a view of
   the roots and the objects that are to be managed should provide a
   visit methods to all their reachable objects.

   A higher level heap can be used that keeps track of the roots by 
   providing a smart pointer that keeps track of other smart pointers
   created during its construction. These smart pointers can provide the visit
   method. This ofcourse has the additional memory overhead of the tracking record
   for each smart pointer object.
   */

#include <cstddef>
#include <type_traits>
#include <memory>
#include <optional>
#include <iterator>
#include <iostream>
#include <exception>
#include <new>

namespace custom
{

/* The heap can be customized by providing a key policy specifying the returned key type.
   This type should be isomorphic to std::size_t for the specified HeapSize. This is
   a predefined policy that provides std::uint_fast32_t keys in order to store them
   homogeneously in our stack.
   */

struct uint_fast32_t_key_policy
{
    // this can always be a custom type.
    using key_type = std::uint_fast32_t;

    // needed for static assertion.
    static std::size_t constexpr can_represent = (std::size_t)1 << 31;

    // In the case of a custom type this can always return a constant true.
    static constexpr bool is_valid(key_type key) 
    {
        return key & ((std::size_t)1 << 31);
    }

    static constexpr std::size_t to_size_t(key_type key) 
    {
        return key & 0x3fffffff;
    }

    static constexpr key_type from_size_t(std::size_t n) 
    {
        return n | ((std::size_t)1 << 31);
    }
};

template <class T, std::size_t HeapSize, class KeyPolicy, class RootsView>
class heap
{
public:
    static_assert(HeapSize <= KeyPolicy::can_represent);

    using key_type = typename KeyPolicy::key_type;

    heap(RootsView roots_view)
        : roots_view_(roots_view)
        , memory_(std::make_unique<heap_node[]>(HeapSize))
        , free_list_{nullptr}
    {
        for (std::size_t i = 0; i != HeapSize; ++i)
        {
            auto p = &memory_[i];
            p->next = free_list_;
            free_list_ = p;
        }
    }

    ~heap()
    {
        for (std::size_t i = 0; i != HeapSize; ++i)
        {
            heap_node& n = memory_[i];
            destroy(n);
        }
    }

    heap(const heap&) = delete;
    heap& operator=(const heap&) = delete;
    //these are already deleted, just making this explicit
    heap(heap&&) = delete;
    heap& operator=(heap&&) = delete;

    template <class... Args>
    key_type add(Args&&... args)
    {
        if (heap_node * p = get_new_node())
        {
            create(*p, std::forward<Args>(args)...);
            return get_key(p);
        }

        struct heap_bad_alloc : std::bad_alloc
        {
            virtual const char * what() const noexcept final override
            {
                return "custom::heap is out of memory";
            }
        };

        throw heap_bad_alloc{};
    }

    T& get(key_type key)
    {
        return *std::launder(reinterpret_cast<T*>(::std::addressof(get_node(key).storage_)));
    }

    T const & get(key_type key) const
    {
        return *std::launder(reinterpret_cast<T const *>(::std::addressof(get_node(key).storage_)));
    }

    void garbage_collect()
    {
        clear();
        mark();
        sweep();
    }

private:
    struct heap_node
    {
        heap_node()
            : storage_{}
            , next{nullptr}
            , marked{false}
            , alive{false}
        {
        }

        std::aligned_storage_t<sizeof(T), alignof(T)> storage_;
        heap_node * next = nullptr;
        bool marked = false;
        bool alive = false;
    };

    key_type get_key(heap_node * p) const
    {
        return KeyPolicy::from_size_t(static_cast<std::size_t>(std::distance(&memory_[0], p)));
    }

    heap_node& get_node(key_type key)
    {
        return memory_[KeyPolicy::to_size_t(key)];
    }

    heap_node * get_new_node()
    {
        if (free_list_ == nullptr)
        {
            garbage_collect();
        }


        if (free_list_ == nullptr)
        {
            return nullptr;
        }

        //pop from free_list_
        heap_node * p = free_list_;
        free_list_ = free_list_->next;


        return p;
    }


    void clear()
    {
        for (std::size_t i = 0; i != HeapSize; ++i)
        {
            memory_[i].marked = false;
        }
    }

    void mark()
    {
        for (key_type key : roots_view_)
        {
            mark(key);
        }
    }

    void mark(key_type key)
    {
        auto & n = get_node(key);

        if (n.marked)
            return;

        n.marked = true;

        auto& p = *std::launder(reinterpret_cast<T*>(::std::addressof(n.storage_)));

        using namespace custom;

        visit_reachable(p, [this](key_type key) { mark(key); });
    }


    void sweep()
    {
        free_list_ = nullptr; 
        for (std::size_t i = 0; i != HeapSize; ++i)
        {
            heap_node& n = memory_[i];

            if (!n.marked)
            {
                destroy(n);
                n.next = free_list_;
                free_list_ = &n;
            }
        }
    }

    template <class... Args>
    void create(heap_node& n, Args&&... args)
    {
        new (::std::addressof(n.storage_)) T(std::forward<Args>(args)...);
        n.alive = true;
    }

    void destroy(heap_node& n)
    {
        if (n.alive)
        {
            //std::launder is needed from c++17 onwards.
            auto p = std::launder(reinterpret_cast<T*>(::std::addressof(n.storage_)));
            std::destroy_at(p);
            n.alive = false;
        }
    }

    RootsView roots_view_;
    std::unique_ptr<heap_node[]> memory_;
    heap_node * free_list_;
};

template <class T, std::size_t HeapSize, class KeyPolicy, class RootsView>
heap<T, HeapSize, KeyPolicy, RootsView> make_heap(RootsView roots_view) { return {roots_view}; } 

}// custom
