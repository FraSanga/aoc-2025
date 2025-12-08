defmodule Beam do
  def enters([[beam] | rows]), do: timelines(rows, %{beam => 1})

  defp timelines([], beams), do: Map.values(beams) |> Enum.sum()
  defp timelines([splitters | rest], b) do
    new_beams = for splitter <- splitters,
        beam = Map.get(b, splitter),
        beam != nil,
        reduce: b do
      beams -> Map.delete(beams, splitter)
              |> Map.update(splitter-1, beam, fn old -> old + beam end)
              |> Map.update(splitter+1, beam, fn old -> old + beam end)
    end
    timelines(rest, new_beams)
  end
end

file = "aoc-7-input.txt"
File.stream!(file)
|> Stream.map(&String.trim(&1) |> then(fn res ->
  String.codepoints(res)
  |> Enum.with_index(fn x, index -> {index, x} end)
  |> Enum.reduce([], fn {index, x}, acc -> if x == ".", do: acc, else: [index | acc] end)
end ))
|> Stream.filter(fn x -> x != [] end)
|> Enum.to_list()
|> then(fn rows -> Beam.enters(rows) end)
|> then(fn code -> IO.puts("#{code}") end)
