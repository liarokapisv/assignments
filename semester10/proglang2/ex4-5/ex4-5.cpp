#include <cstddef>
#include <exception>
#include <utility>
#include <iostream>
#include <vector>
#include <type_traits>
#include <fstream>
#include <iomanip>
#include <chrono>
#include <custom/heap.hpp>
#include <custom/view_adaptors.hpp>
#include <custom/instructions.hpp>

bool constexpr debug_on = false;

namespace
{

std::byte constexpr HALT =   std::byte{0x00};
std::byte constexpr JUMP =   std::byte{0x01};
std::byte constexpr JNZ =    std::byte{0x02};
std::byte constexpr DUP =    std::byte{0x03};
std::byte constexpr SWAP =   std::byte{0x04};
std::byte constexpr DROP =   std::byte{0x05};
std::byte constexpr PUSH4 =  std::byte{0x06};
std::byte constexpr PUSH2 =  std::byte{0x07};
std::byte constexpr PUSH1 =  std::byte{0x08};
std::byte constexpr ADD =    std::byte{0x09};
std::byte constexpr SUB =    std::byte{0x0a};
std::byte constexpr MUL =    std::byte{0x0b};
std::byte constexpr DIV =    std::byte{0x0c};
std::byte constexpr MOD =    std::byte{0x0d};
std::byte constexpr EQ =     std::byte{0x0e};
std::byte constexpr NE =     std::byte{0x0f};
std::byte constexpr LT =     std::byte{0x10};
std::byte constexpr GT =     std::byte{0x11};
std::byte constexpr LE =     std::byte{0x12};
std::byte constexpr GE =     std::byte{0x13};
std::byte constexpr INOT =   std::byte{0x14};
std::byte constexpr IAND =   std::byte{0x15};
std::byte constexpr IOR =    std::byte{0x16};
std::byte constexpr INPUT =  std::byte{0x17};
std::byte constexpr OUTPUT = std::byte{0x18};
std::byte constexpr CLOCK =  std::byte{0x2a};
std::byte constexpr CONS = std::byte{0x30};
std::byte constexpr HD = std::byte{0x31};
std::byte constexpr TL = std::byte{0x32};

auto read_input(char const * file_name)
{
    std::ifstream file(file_name, std::ios::ate | std::ios::binary);
    auto length = file.tellg();
    file.seekg(0);

    std::vector<std::byte> content(length);
    file.read((char*)content.data(), length);

    return content;
}

using key_policy = custom::uint_fast32_t_key_policy;

class cons_cell
{
public:
    template <class Arg1, class Arg2>
    cons_cell(Arg1&& arg1, Arg2&& arg2)
        : hd(std::forward<Arg1>(arg1))
        , tl(std::forward<Arg2>(arg2))
    {
    }

    template <class Visit>
    friend void visit_reachable(const cons_cell& cell, Visit&& visit) 
    {
        if (key_policy::is_valid(cell.hd))
            visit(cell.hd);

        if (key_policy::is_valid(cell.tl))
            visit(cell.tl);
    }

    std::uint_fast32_t hd;
    std::uint_fast32_t tl;
};

} // namespace

int main(int argc, char * argv[])
{       
    if (argc != 2)
        throw std::logic_error("Invalid number of arguments");

    auto bytecode = read_input(argv[1]);

    std::vector<std::uint_fast32_t> stack;
    stack.reserve(2 << 26);

    auto roots_view = custom::make_view_adaptor<custom::filter_view_adaptor>(
            stack, 
            [](auto a) { return key_policy::is_valid(a); });

    static constexpr std::size_t heap_size = std::size_t{1} << 20;

    auto heap = custom::make_heap<cons_cell, heap_size, key_policy>(roots_view);

    /* The below lambdas help to make the instructions data-agnostic. This has helped a lot 
       while testing different approaches.
    */

    auto start_time = std::chrono::high_resolution_clock::now();

    std::size_t ip = 0;

    auto get_byte = [&]{
        if constexpr (debug_on)
        {
            if (ip >= bytecode.size())
                throw std::runtime_error("Instruction pointer out of bytecode limits");
        }

        return bytecode[ip++];
    };

    auto set_ip = [&](auto const & v) { 
        if constexpr (debug_on)
        {
            if (static_cast<std::size_t>(v) >= bytecode.size()) 
                throw std::runtime_error("Instruction (" + std::to_string(ip) + "): Attempted to jump to invalid instruction address");
        }

        ip = v;
    };

    bool running = true;

    auto stop = [&] { running = false; };

    auto push = [&](auto v) { 
        stack.emplace_back(v);
    };

    auto pop = [&] {
        if constexpr (debug_on)
        {
            if (stack.empty()) 
                throw std::runtime_error("Instruction (" + std::to_string(ip) + "): Attempted to pop value from empty stack."); 
        }
        
        auto t = stack.back();

        stack.pop_back();

        return t;
    };
        
    auto get = [&](std::size_t i){ 
        if constexpr (debug_on)
        {
            if (i >= stack.size())
                throw std::runtime_error("Given stack index (" + std::to_string(i) + ") is not valid.");
        }

        return stack[stack.size() - i - 1];
    };

    auto insert = [&](std::size_t i, auto v) 
    {
        stack[stack.size() - i - 1] = v;
    };

    auto input = []{ char c; std::cin >> c; return c; };
    auto output = [](char c){ std::cout << c << std::flush; };
    auto clock = [&]{ std::cout << std::fixed << std::setprecision(6) << 
                        std::chrono::duration_cast<std::chrono::duration<float>>(
                                std::chrono::high_resolution_clock::now() - 
                                start_time).count() << std::endl;
                    };

    auto create = [&](auto p1, auto p2) { 
        return heap.add(p1, p2);
    };

    auto hd = [&](auto & c) { return heap.get(c).hd; };
    auto tl = [&](auto & c) { return heap.get(c).tl; };

    std::cout << "starts running" << std::endl;

    while(running)
    {
        switch(bytecode[ip++])
        {
            case HALT:
                custom::halt(stop);
                break;
            case JUMP:
                custom::jump(get_byte,  set_ip);
                break;
            case JNZ:
                custom::jnz(get_byte, set_ip, pop);
                break;
            case DUP:
                custom::dup(get_byte, get, push);
                break;
            case SWAP:
                custom::swap(get_byte, get, insert);
                break;
            case DROP:
                custom::drop(pop);
                break;
            case PUSH4:
                custom::push4(get_byte, push);
                break;
            case PUSH2:
                custom::push2(get_byte, push);
                break;
            case PUSH1:
                custom::push1(get_byte, push);
                break;
            case ADD:
                custom::add(pop, push);
                break;
            case SUB:
                custom::sub(pop, push);
                break;
            case MUL:
                custom::mul(pop, push);
                break;
            case DIV:
                custom::div(pop, push);
                break;
            case MOD:
                custom::mod(pop, push);
                break;
            case EQ:
                custom::eq(pop, push);
                break;
            case NE:
                custom::ne(pop, push);
                break;
            case LT:
                custom::lt(pop, push);
                break;
            case GT:
                custom::gt(pop, push);
                break;
            case LE:
                custom::le(pop, push);
                break;
            case GE:
                custom::ge(pop, push);
                break;
            case INOT:
                custom::inot(pop, push);
                break;
            case IAND:
                custom::iand(pop, push);
                break;
            case IOR:
                custom::ior(pop, push);
                break;
            case INPUT:
                custom::input(push, input);
                break;
            case OUTPUT:
                custom::output(pop, output);
                break;
            case CLOCK:
                custom::clock(clock);
                break;
            case CONS:
                custom::cons(pop, push, create);
                break;
            case HD:
                custom::hd(pop, push, hd);
                break;
            case TL:
                custom::tl(pop, push, tl);
                break;
            default:
                break;
        }
    }
    


    return 0;
}


