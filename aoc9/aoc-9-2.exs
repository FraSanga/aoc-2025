defmodule Floor do
  def max_empty_rectangle(tiles, _, max \\ 0)
  def max_empty_rectangle([], _, max), do: max
  def max_empty_rectangle([{x, y} | tiles], lines, max) do
    new_max = for {a, b} <- tiles,
          max_x = max(a, x),
          min_x = min(a, x),
          max_y = max(b, y),
          min_y = min(b, y),
          area = (abs(x - a)+1) * (abs(y - b)+1),
        reduce: max do
      curr ->
        if area > curr and not Enum.any?(lines, fn line -> cut?(line, {min_x, max_x, min_y, max_y}) end),
          do: area, else: curr
        end
    max_empty_rectangle(tiles, lines, new_max)
  end

  def lines(tiles) do
    do_lines(tiles, [{List.last(tiles), List.first(tiles)}])
  end
  defp do_lines([_ | []], acc), do: acc
  defp do_lines([tile | tiles], acc) do
    do_lines(tiles, [{tile, List.first(tiles)} | acc])
  end

  defp cut?({{x, y1}, {x, y2}}, {min_x, max_x, min_y, max_y}) do
    cond do
      x <= min_x -> false
      x >= max_x -> false
      y1 <= min_y and y2 <= min_y -> false
      y1 >= max_y and y2 >= max_y -> false
      true -> true
    end
  end
  defp cut?({{x1, y}, {x2, y}}, {min_x, max_x, min_y, max_y}) do
    cond do
      y <= min_y -> false
      y >= max_y -> false
      x1 <= min_x and x2 <= min_x -> false
      x1 >= max_x and x2 >= max_x -> false
      true -> true
    end
  end
end

file = "aoc-9-input.txt"
File.stream!(file)
|> Stream.map(&String.trim(&1)
              |> then(fn str -> String.split(str, ",") end)
              |> then(fn [str_y, str_x] -> {String.to_integer(str_x), String.to_integer(str_y)} end))
|> Enum.to_list()
|> then(fn tiles -> Floor.max_empty_rectangle(tiles, Floor.lines(tiles)) end)
|> then(fn code -> IO.puts("#{code}") end)
