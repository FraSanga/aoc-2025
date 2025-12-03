defmodule IDsChecker do
  def check_range(range) do
    [low_str, high_str] = String.split(range, "-", parts: 2)
    low_len = String.length(low_str)
    high_len = String.length(high_str)
    generate_subranges(low_str, high_str, low_len, high_len, [])
    |> Enum.reduce(
      0,
      fn {new_low_str, new_high_str, new_len}, acc ->
        check_subrange(new_low_str, new_high_str, new_len)
        |> Enum.sum()
        |> then(& acc + &1)
      end
    )
  end

  defp generate_subranges(low_str, high_str, len, len, acc), do: [{low_str, high_str, len} | acc]
  defp generate_subranges(low_str, high_str, low_len, high_len, acc) when low_len < high_len do
    new_low_str = "1" <> String.duplicate("0", low_len)
    new_high_str = String.duplicate("9", low_len)
    generate_subranges(new_low_str, high_str, low_len + 1, high_len, [{low_str, new_high_str, low_len} | acc])
  end

  defp check_subrange(_, _, 1), do: []
  defp check_subrange(low_str, high_str, len) do
    divisors = divisors(len)
    Enum.flat_map(
      divisors,
      fn divisor ->
        generate_invalid_ids(low_str, high_str, len, divisor)
      end
    ) |> Enum.uniq()
  end

  defp divisors(1), do: []
  defp divisors(n), do: [1 | divisors(2,n,:math.sqrt(n))] |> Enum.sort
  defp divisors(k,_n,q) when k>q, do: []
  defp divisors(k,n,q) when rem(n,k)>0, do: divisors(k+1,n,q)
  defp divisors(k,n,q) when k * k == n, do: [k | divisors(k+1,n,q)]
  defp divisors(k,n,q)                , do: [k,div(n,k) | divisors(k+1,n,q)]

  defp generate_invalid_ids(low_str, high_str, len, divisor) do
    to_repeat = div(len,divisor)
    prefix = String.slice(low_str, 0..divisor-1)

    {valid, bound} = prefix
    |> String.duplicate(to_repeat)
    |> validate_lower_bound(low_str)

    if valid do
      do_generate_invalid_ids(bound, high_str, len, divisor, [])
    else
      id_str = next_id(prefix, to_repeat)
      cond do
        String.length(id_str) > len -> []
        String.to_integer(id_str) > String.to_integer(high_str) -> []
        true -> generate_invalid_ids(id_str, high_str, len, divisor)
      end
    end
  end

  defp validate_lower_bound(bound, low_str), do: {bound >= low_str, bound}
  defp next_id(prefix, to_repeat) do
    String.to_integer(prefix)
    |> then(& &1+1)
    |> Integer.to_string()
    |> String.duplicate(to_repeat)
  end

  defp do_generate_invalid_ids(id_str, high_str, len, divisor, acc) do
    to_repeat = div(len,divisor)
    prefix = String.slice(id_str, 0..divisor-1)
    new_id_str = next_id(prefix, to_repeat)
    high = String.to_integer(high_str)

    cond do
      String.length(id_str) > len -> acc
      String.to_integer(id_str) > high -> acc
      String.length(new_id_str) > len -> [String.to_integer(id_str) | acc]
      String.to_integer(new_id_str) > high -> [String.to_integer(id_str) | acc]
      true -> do_generate_invalid_ids(new_id_str, high_str, len, divisor, [String.to_integer(id_str) | acc])
    end
  end
end

file = "aoc-2-input.txt"
File.stream!(file)
|> Stream.map(&String.split(&1,",", trim: true))
|> Enum.to_list()
|> List.first()
|> Enum.reduce(0, fn range, acc -> IDsChecker.check_range(range) + acc end)
|> then(fn code ->IO.puts("#{code}") end)
