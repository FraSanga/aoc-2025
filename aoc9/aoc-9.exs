defmodule Floor do
  def max_rectangle(tiles, max \\ 0)
  def max_rectangle([], max), do: max
  def max_rectangle([{x, y} | tiles], max) do
    new_max = for {a, b} <- tiles,
        area = (abs(x - a)+1) * (abs(y - b)+1),
        reduce: max do
      curr -> if curr < area, do: area, else: curr
    end
    max_rectangle(tiles, new_max)
  end
end

file = "aoc-9-input.txt"
File.stream!(file)
|> Stream.map(&String.trim(&1)
              |> then(fn str -> String.split(str, ",") end)
              |> then(fn [str_y, str_x] -> {String.to_integer(str_x), String.to_integer(str_y)} end))
|> Enum.to_list()
|> then(fn tiles -> Floor.max_rectangle(tiles) end)
|> then(fn code -> IO.puts("#{code}") end)
