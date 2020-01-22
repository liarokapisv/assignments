#include <cstddef>
#include <cstdint>
#include <memory>
#include <exception>
#include <fstream>
#include <vector>
#include <chrono>
#include <iostream>
#include <iomanip>
#include <iterator>

template <class Container>
struct Heap
{
    struct Node
    {
        std::uint32_t hd;
        std::uint32_t tl;
        Node * next;
        bool marked;
    };

    Heap(Container& stack, std::size_t size)
        : stack(stack)
        , size(size)
        , dt(new Node[size]) {
              fl = 0;
              for (std::size_t i = 0; i != size; ++i) {
                  Node * p = &dt[i];
                  p->next = fl;
                  fl = p;
              }
          }

    std::uint32_t add(std::uint32_t& hd, std::uint32_t& tl) {
        if (fl == 0) {
            garbage_collect();
            if (fl == 0) {
                throw std::bad_alloc();
            }
        }

        Node * p = fl;
        p->hd = hd;
        p->tl = tl;
        fl = fl->next;

        std::uint32_t key = static_cast<std::size_t>(std::distance(&dt[0], p)) | ((std::size_t)1 << 31);

        return key;
    }

    std::uint32_t& hd(std::uint32_t key)
    {
        return dt[key & 0x3fffffff].hd;
    }

    std::uint32_t& tl(std::uint32_t key)
    {
        return dt[key & 0x3fffffff].tl;
    }

    void garbage_collect() {
        for (std::size_t i = 0; i != size; ++i) {
            dt[i].marked = false; 
        }

        for (std::size_t i = 0; i != stack.size(); ++i) {
            if (stack[i] & (1 << 31)) {
                mark(stack[i]);
            }
        }

        fl = 0;
        for (std::size_t i = 0; i != size; ++i) {
            if (!dt[i].marked) {
                dt[i].next = fl;
                fl = &dt[i];
            }
        }
    }

    void mark(std::uint32_t key)
    {
        Node * p = &dt[key & 0x3fffffff];

        if (p->marked)
            return;

        p->marked = true;

        if (p->hd & (1 << 31))
            mark(p->hd);

        if (p->tl & (1 << 31))
            mark(p->tl);
    }

    Container& stack;
    std::size_t size;
    std::unique_ptr<Node[]> dt;
    Node * fl;
};

#define HALT 0x00
#define JUMP 0x01
#define JNZ 0x02
#define DUP 0x03
#define SWAP 0x04
#define DROP 0x05
#define PUSH4 0x06
#define PUSH2 0x07
#define PUSH1 0x08
#define ADD 0x09
#define SUB 0x0a
#define MUL 0x0b
#define DIV 0x0c
#define MOD 0x0d
#define EQ 0x0e
#define NE 0x0f
#define LT 0x10
#define GT 0x11
#define LE 0x12
#define GE 0x13
#define INOT 0x14
#define IAND 0x15
#define IOR 0x16
#define INPUT 0x17
#define OUTPUT 0x18
#define CLOCK 0x2a
#define CONS 0x30
#define HD 0x31
#define TL 0x32

std::vector<unsigned char> read_input(char const * file_name)
{
    std::ifstream file(file_name, std::ios::ate | std::ios::binary);
    auto length = file.tellg();
    file.seekg(0);

    std::vector<unsigned char> content(length);
    file.read((char*)content.data(), length);

    return content;
}

int main(int argc, char * argv[])
{

    std::vector<unsigned char> bytecode = read_input(argv[1]); 

    auto start_time = std::chrono::high_resolution_clock::now();
    std::size_t ip = 0;
    bool running = true;

    std::vector<std::uint32_t> stack;
    stack.reserve(2 << 26);
    Heap<std::vector<std::uint32_t>> heap(stack, (1 << 20));

    while (running)
    {
        switch (bytecode[ip++])
        {
            case HALT:
                {
                    running = false;
                    break;
                }
            case JUMP:
                {
                    unsigned char b1 = bytecode[ip++];
                    unsigned char b2 = bytecode[ip++];
                    ip = ((std::uint16_t)b2 << 8) | (std::uint16_t)b1;
                    break;
                }
            case JNZ:
                {
                    unsigned char b1 = bytecode[ip++];
                    unsigned char b2 = bytecode[ip++];
                    std::uint32_t v = stack.back(); stack.pop_back();
                    if (v) {
                        ip = ((std::uint16_t)b2 << 8) | (std::uint16_t)b1;
                    }
                    break;
                }
            case DUP:
                {
                    unsigned char i = bytecode[ip++];
                    std::uint32_t v = stack[stack.size() - i -1];
                    stack.push_back(v);
                    break;
                }
            case SWAP:
                {
                    unsigned char i = bytecode[ip++];
                    std::swap(stack.back(), stack[stack.size() - i -1]);
                    break;
                }
            case DROP:
                {
                    stack.pop_back();
                    break;
                }
            case PUSH4:
                {
                    unsigned char b1 = bytecode[ip++];
                    unsigned char b2 = bytecode[ip++];
                    unsigned char b3 = bytecode[ip++];
                    unsigned char b4 = bytecode[ip++];
                    std::int32_t res = 
                        ((std::int32_t)b4 << 24) | 
                        ((std::int32_t)b3 << 16) | 
                        ((std::int32_t)b2 << 8) | 
                        (std::int32_t)b1;
                    stack.push_back((std::uint32_t)res);
                    break;
                }
            case PUSH2:
                {
                    unsigned char b1 = bytecode[ip++];
                    unsigned char b2 = bytecode[ip++];
                    std::int32_t res = 
                        ((std::int32_t)b2 << 8) | 
                        (std::int32_t)b1;
                    stack.push_back((std::uint32_t)res);
                    break;
                }
            case PUSH1:
                {
                    unsigned char b1 = bytecode[ip++];
                    std::int32_t res = (std::int32_t)b1;
                    stack.push_back((std::uint32_t)res);
                    break;
                }
            case ADD:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 + op2);
                    break;
                }
            case SUB:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 - op2);
                    break;
                }
            case MUL:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 * op2);
                    break;
                }
            case DIV:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 / op2);
                    break;
                }
            case MOD:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 % op2);
                    break;
                }
            case EQ:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 == op2);
                    break;
                }
            case NE:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 != op2);
                    break;
                }
            case LT:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 < op2);
                    break;
                }
            case GT:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 > op2);
                    break;
                }
            case LE:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 <= op2);
                    break;
                }
            case GE:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 >= op2);
                    break;
                }
            case INOT:
                {
                    std::uint32_t op = stack.back(); stack.pop_back();
                    stack.push_back(!op);
                    break;
                }
            case IAND:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 && op2);
                    break;
                }
            case IOR:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    stack.push_back(op1 || op2);
                    break;
                }
            case INPUT:
                {
                    char c;
                    std::cin >> c;
                    stack.push_back((std::uint32_t)c);
                    break;
                }
            case OUTPUT:
                {
                    std::uint32_t op = stack.back(); stack.pop_back();
                    char c = (char) op;
                    std::cout << c << std::flush;
                    break;
                }
            case CLOCK:
                {
                    std::cout << std::fixed << std::setprecision(6) << 
                        std::chrono::duration_cast<std::chrono::duration<float>>(
                                std::chrono::high_resolution_clock::now() - 
                                start_time).count() << std::endl;
                    break;
                }
            case CONS:
                {
                    std::uint32_t op2 = stack.back(); stack.pop_back();
                    std::uint32_t op1 = stack.back(); stack.pop_back();
                    std::uint32_t key = heap.add(op1, op2);
                    stack.push_back(key);
                    break;
                }
            case HD:
                {
                    std::uint32_t key = stack.back(); stack.pop_back();
                    std::uint32_t hd = heap.hd(key);
                    stack.push_back(hd);
                    break;
                }
            case TL:
                {
                    std::uint32_t key = stack.back(); stack.pop_back();
                    std::uint32_t tl = heap.tl(key);
                    stack.push_back(tl);
                    break;
                }
        }

    }

    return 0;
}



