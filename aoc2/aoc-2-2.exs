defmodule IDsChecker do
  def check_range(range) do
    [low_str, high_str] = String.split(range, "-", parts: 2)
    low_len = String.length(low_str)
    high_len = String.length(high_str)
    generate_subranges(low_str, high_str, low_len, high_len, []) |> dbg()
    |> Enum.reduce(
      0,
      fn {new_low_str, new_high_str, new_len}, acc ->
        check_subrange(new_low_str, new_high_str, new_len)
        |> Enum.sum()
        |> then(& acc + &1) |> dbg()
      end
    )
  end

  defp generate_subranges(low_str, high_str, len, len, acc), do: [{low_str, high_str, len} | acc]
  defp generate_subranges(low_str, high_str, low_len, high_len, acc) when low_len < high_len do
    new_low_str = "1" <> String.duplicate("0", low_len)
    new_high_str = String.duplicate("9", low_len)
    generate_subranges(new_low_str, high_str, low_len + 1, high_len, [{low_str, new_high_str, low_len} | acc])
  end

  defp generate_prime_divisors(1), do: []
  defp generate_prime_divisors(2), do: [1]
  defp generate_prime_divisors(len) when rem(len,2)==0 do
    for i <- Prime.take(2, div(len,2)),
        rem(len,i) == 0,
        reduce: [] do
      acc -> [i | acc]
    end
  end
  defp generate_prime_divisors(len) do
    for i <- Prime.take(1, div(len,2)),
        rem(len,i) == 0,
        reduce: [] do
      acc -> [i | acc]
    end
  end

  # Find initial digits that cannot change
  defp find_equal_start(<<head, low_rest::binary>>, <<head, high_rest::binary>>, acc) do
    find_equal_start(low_rest, high_rest, acc <> <<head>>)
  end
  defp find_equal_start(_, _, acc), do: acc

  defp check_subrange(low_str, high_str, 1), do: []
  defp check_subrange(low_str, high_str, len) do
    divisors = generate_prime_divisors(len)
    prefix = find_equal_start(low_str, high_str, "") |> dbg()
    Enum.flat_map(
      divisors,
      fn divisor ->
        generate_invalid_ids(prefix, low_str, high_str, len, divisor)
      end
    ) |> Enum.uniq()
  end

  defp do_generate_invalid_ids("", start_str, high_str, len, divisor) do
    [start_str, high_str, len, divisor] |> dbg()
    high = String.to_integer(high_str)
    # TO-DO: fix generate_invalid_ids
    []
  end

  # TO-DO: fix
  # skip first isn't work as aspected (too large skip)
  defp generate_invalid_ids("", low_str, high_str, len, divisor) when low_str < high_str do
    first = String.first(low_str)
    skip_first = for i <- 1..(div(len,divisor)-1)//1,
        n = String.at(low_str,divisor*i),
        reduce: [] do
      acc -> [n | acc]
    end |> Enum.any?(fn n -> n > first end) |> dbg()

    if skip_first do
      cond do
        first == "9" -> []
        true ->
          new_low_str = Integer.to_string((String.to_integer(first) + 1)) <> String.duplicate("0", divisor-1)
          |> String.duplicate(div(len,divisor))
          generate_invalid_ids("", new_low_str, high_str, len, divisor)
      end
    else
      rest_len = divisor-1
      rest = String.slice(low_str,1..(rest_len)//1)
      skip_rest = for i <- 1..(div(len,divisor)-1)//1,
          n = String.slice(low_str,((divisor*i)+1)..((divisor*i)+rest_len)//1),
          reduce: [] do
        acc -> [n | acc]
      end |> Enum.any?(fn n -> n > rest end) |> dbg()

      if skip_rest do
        cond do
          rest == "" ->
            new_low_str = String.duplicate(first, len)
            do_generate_invalid_ids("", new_low_str, high_str, len, divisor)
          rest == String.duplicate("9", rest_len) ->
            new_low_str = Integer.to_string((String.to_integer(first) + 1)) <> String.duplicate("0", divisor-1)
            |> String.duplicate(div(len,divisor))
            do_generate_invalid_ids("", new_low_str, high_str, len, divisor)
          true ->
            new_low_str = first <> String.pad_leading(Integer.to_string((String.to_integer(rest) + 1)), divisor-1, "0")
            |> String.duplicate(div(len,divisor))
            do_generate_invalid_ids("", new_low_str, high_str, len, divisor)
        end
      else
        new_low_str = String.duplicate(first <> rest, div(len,divisor))
        do_generate_invalid_ids("", new_low_str, high_str, len, divisor)
      end
    end

  end

  # TO-DO: implement logic with prefix
  defp generate_invalid_ids(prefix, low_str, high_str, len, divisor) do
    []
  end

end

defmodule Prime do
  def take(from, to) when from < 1 or to < 1, do: raise ArgumentError
  def take(from, to), do: from |> Stream.iterate(&(&1+1)) |> Stream.filter(&prime?/1) |> Enum.take_while(&(&1 <= to))
  defp prime?(n) when n in [1,2,3], do: true
  defp prime?(n), do: Enum.all?(2..floor(n**1/2),&(rem(n,&1)!=0))
end




file = "aoc-2-input.txt"
File.stream!(file)
|> Stream.map(&String.split(&1,",", trim: true))
|> Enum.to_list()
|> List.first()
|> Enum.reduce(0, fn range, acc -> IDsChecker.check_range(range) + acc end)
#|> then(fn code ->IO.puts("#{code}") end)
