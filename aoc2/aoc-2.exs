defmodule IDsChecker do
  def check_range(range) do
    [low_str, high_str] = String.split(range, "-", parts: 2)
    low_len = String.length(low_str)
    high_len = String.length(high_str)

    prefix = if low_len == high_len, do: find_equal_start(low_str, high_str, ""), else: ""
    generate_invalid_ids(prefix, low_str, high_str, low_len, high_len)
    |> Enum.sum()
  end

  # Find initial digits that cannot change
  defp find_equal_start(<<head, low_rest::binary>>, <<head, high_rest::binary>>, acc) do
    find_equal_start(low_rest, high_rest, acc <> <<head>>)
  end
  defp find_equal_start(_, _, acc), do: acc

  # Generate all possible ids without a fixed prefix
  defp generate_invalid_ids("", _, _, len, len) when rem(len,2) == 1, do: []
  defp generate_invalid_ids("", low_str, high_str, len, len) do
    low = String.to_integer(low_str)
    high = String.to_integer(high_str)

    for i <- low..high,
        div(i,10**div(len,2)) == rem(i,10**div(len,2)),
        reduce: [] do
      acc -> [i | acc]
    end
  end
  # Jump to the nearest lower bound with an even length
  defp generate_invalid_ids("", _, high_str, low_len, high_len) when rem(low_len,2) == 1 do
    new_low_str = Integer.to_string(10**low_len)
    prefix = if low_len + 1 == high_len, do: find_equal_start(new_low_str, high_str, ""), else: ""
    generate_invalid_ids(prefix, new_low_str, high_str, low_len + 1, high_len)
  end
  # Jump to the nearest upper bound with an even length
  defp generate_invalid_ids("", low_str, _, low_len, high_len) when rem(high_len,2) == 1 do
    new_high_str = Integer.to_string((10**(high_len-1))-1)
    prefix = if low_len + 1 == high_len, do: find_equal_start(low_str, new_high_str, ""), else: ""
    generate_invalid_ids(prefix, low_str, new_high_str, low_len, high_len - 1)
  end

  # Generate all possible ids with a fixed prefix
  defp generate_invalid_ids(prefix_str, low_str, high_str, len, len) do
    prefix_len = String.length(prefix_str)
    prefix = String.to_integer(prefix_str)
    low = String.to_integer(low_str)
    high = String.to_integer(high_str)
    half_len = div(len,2)
    cond do
      prefix_len == half_len ->
        number = prefix * (10**half_len + 1)
        if number in low..high, do: [number], else: []
      prefix_len > half_len ->
        half = div(prefix,10**(prefix_len-half_len))
        number = half * (10**half_len + 1)
        if number in low..high, do: [number], else: []
      prefix_len < half_len ->
        dim = half_len - prefix_len
        prefix_low = div(low,10**half_len) |> rem(10**dim)
        prefix_high = div(high,10**half_len) |> rem(10**dim)
        for i <- prefix_low..prefix_high,
            n = (prefix * (10**(dim)) + i) * (10**half_len + 1),
            n in low..high,
            reduce: [] do
          acc -> [n | acc]
        end
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
