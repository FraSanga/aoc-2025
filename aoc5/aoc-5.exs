defmodule Inventory do
  def merge_ranges([], acc), do: acc
  def merge_ranges([new_range_str | rest], acc) do
    [first, last] = String.split(new_range_str, "-")
    new_range = Range.new(String.to_integer(first), String.to_integer(last), 1)

    new_ranges = case Enum.group_by(
      acc,
      fn range -> Range.disjoint?(range, new_range) end)
    do
      %{true => ranges, false => ranges_to_merge} -> [merge(ranges_to_merge, new_range) | ranges]
      %{false => ranges_to_merge} -> [merge(ranges_to_merge, new_range)]
      %{true => ranges} -> [new_range | ranges]
      %{} -> [new_range]
    end
    merge_ranges(rest, new_ranges)
  end

  def count_fresh_ingredients(_, [], count), do: count
  def count_fresh_ingredients(ranges, [ingredient_str | rest], count) do
    ingredient = String.to_integer(ingredient_str)
    if Enum.any?(ranges, fn range -> ingredient in range end) do
      count_fresh_ingredients(ranges, rest, count + 1)
    else
      count_fresh_ingredients(ranges, rest, count)
    end
  end

  defp merge([], range), do: range
  defp merge([first1..last1//1 | t], first2..last2//1) do
    last = max(last1, last2)
    first = min(first1, first2)
    merge(t, Range.new(first, last, 1))
  end
end

chunk_fun = fn element, acc ->
  if element == "" do
    {:cont, Enum.reverse(acc), []}
  else
    {:cont, [element | acc]}
  end
end
after_fun = fn
  [] -> {:cont, []}
  acc -> {:cont, Enum.reverse(acc), []}
end

file = "aoc-5-input.txt"
File.stream!(file)
|> Stream.map(&String.trim/1)
|> Stream.chunk_while([], chunk_fun, after_fun)
|> Enum.to_list()
|> then(fn [ranges, ingredients] -> Inventory.merge_ranges(ranges, []) |> Inventory.count_fresh_ingredients(ingredients, 0) end)
|> then(fn code -> IO.puts("#{code}") end)
