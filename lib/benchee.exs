# squares = for f <- ?a..?h, r <- ?1..?8, do: to_string([f,r])
# squares = Enum.shuffle(squares)

# Benchee.run(%{
#   calc: fn -> Enum.map(squares, &ExChecker.FEN.Parser.sq_to_index/1) end,
#   lookup: fn -> Enum.map(squares, &ExChecker.FEN.Parser.sq_to_index_lookup/1) end
# }, time: 10, memory_time: 2)


# Benchmarking calc...
# Benchmarking lookup...

# Name             ips        average  deviation         median         99th %
# lookup      211.97 K        4.72 μs   ±674.68%           4 μs           9 μs
# calc         89.77 K       11.14 μs   ±145.51%          10 μs          22 μs

# Comparison:
# lookup      211.97 K
# calc         89.77 K - 2.36x slower

# Memory usage statistics:

# Name      Memory usage
# lookup         5.09 KB
# calc           7.06 KB - 1.39x memory usage

# **All measurements for memory usage were the same**
# ➜  ex_checker git:(engine) ✗
