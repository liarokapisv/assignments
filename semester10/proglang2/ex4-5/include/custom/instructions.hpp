#pragma once

/* Provides templates for the supported instructions.
   They are designed to be used with functors that provide
   the low-level operations in order to make these independent
   from the underlying representation (almost, we still need to do byte conversions
   which leaks information).
   */

namespace custom
{

template <class Stop>
void halt(Stop stop)
{
    stop();
}

template <class GetByte, class SetIp>
void jump(GetByte get_byte, SetIp set_ip)
{
    auto b1 = get_byte();
    auto b2 = get_byte();
    set_ip(((std::uint16_t)b2 << 8) | (std::uint16_t)b1);
}

template <class GetByte, class SetIp, class Pop>
void jnz(GetByte get_byte, SetIp set_ip, Pop pop)
{
    auto b1 = get_byte();
    auto b2 = get_byte();
    auto v = pop();  
    if (v) set_ip(((std::uint16_t)b2 << 8) | (std::uint16_t)b1);
}

template <class GetByte, class Get, class Push>
void dup(GetByte get_byte, Get get, Push push)
{
    auto target = get_byte();
    auto t = get((std::uint8_t)target);
    push(t);
}

template <class GetByte, class Get, class Insert>
void swap(GetByte get_byte, Get get, Insert insert)
{
    auto target = get_byte();
    auto l = get(0);
    auto r = get((std::uint8_t)target);
    insert((std::uint16_t)target, l);
    insert(0, r);
}

template <class Pop>
void drop(Pop pop)
{
    pop();
}

template <class GetByte, class Push>
void push4(GetByte get_byte, Push push)
{
    auto b1 = get_byte();
    auto b2 = get_byte();
    auto b3 = get_byte();
    auto b4 = get_byte();

    std::int_fast32_t res = ((std::int_fast32_t)b4 << 24) | ((std::int_fast32_t)b3 << 16) | ((std::int_fast32_t)b2 << 8) | (std::int_fast32_t)b1;
    push((std::uint_fast32_t)res);
}

template <class GetByte, class Push>
void push2(GetByte get_byte, Push push)
{
    auto b1 = get_byte();
    auto b2 = get_byte();

    std::int_fast32_t res = ((std::int_fast32_t)b2 << 8) | (std::int_fast32_t)b1;
    push((std::uint_fast32_t)res);
}

template <class GetByte, class Push>
void push1(GetByte get_byte, Push push)
{
    auto b1 = get_byte();

    std::int_fast32_t res = (std::int_fast32_t)b1;
    push((std::uint_fast32_t)res);
}


template <class Pop, class Push>
void add(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push(op1 + op2);
}

template <class Pop, class Push>
void sub(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push(op1 - op2);
}

template <class Pop, class Push>
void mul(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push(op1 * op2);
}

template <class Pop, class Push>
void div(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push(op1 / op2);
}

template <class Pop, class Push>
void mod(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push(op1 % op2);
}

template <class Pop, class Push>
void eq(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push((std::uint_fast32_t)(op1 == op2));
}

template <class Pop, class Push>
void ne(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push((std::uint_fast32_t)(op1 != op2));
}

template <class Pop, class Push>
void lt(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push((std::uint_fast32_t)(op1 < op2));
}

template <class Pop, class Push>
void gt(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push((std::uint_fast32_t)(op1 > op2));
}

template <class Pop, class Push>
void le(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push((std::uint_fast32_t)(op1 <= op2));
}

template <class Pop, class Push>
void ge(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();
    push((std::uint_fast32_t)(op1 >= op2));
}

template <class Pop, class Push>
void inot(Pop pop, Push push)
{
    auto op = pop();

    push((std::uint_fast32_t)(!op));
}

template <class Pop, class Push>
void iand(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();

    push((std::uint_fast32_t)(op1 && op2));
}

template <class Pop, class Push>
void ior(Pop pop, Push push)
{
    auto op2 = pop();
    auto op1 = pop();

    push((std::uint_fast32_t)(op1 | op2));
}

template <class Push, class Input>
void input(Push push, Input input)
{
    char c = input();
    push((std::uint_fast32_t)c);
}


template <class Pop, class Output>
void output(Pop pop, Output output)
{
    char op = pop();
    output(op);
}

template <class Clock>
void clock(Clock clock)
{
    clock();
}

template <class Pop, class Push, class Create>
void cons(Pop pop, Push push, Create create)
{
    auto op2 = pop();
    auto op1 = pop();

    push(create(std::move(op1), std::move(op2)));
}

template <class Pop, class Push, class Hd>
void hd(Pop pop, Push push, Hd hd)
{
    auto p = pop();
    push(std::move(hd(p)));
}

template <class Pop, class Push, class Tl>
void tl(Pop pop, Push push, Tl tl)
{
    auto p = pop();
    push(std::move(tl(p)));
}

} // custom
