defmodule Beams do
  def split(line, beams, splitted) do
    if MapSet.size(beams) == 0 do
      beam = Enum.find_index(line, fn x -> x == "S" end)
      {splitted, MapSet.put(beams, beam)}
    else
      {continue, to_split} = MapSet.split_with(beams, fn i -> Enum.at(line, i) != "^" end)
      if MapSet.size(to_split) == 0 do
        {splitted, beams}
      else
        {split, new_beams} = for beam <- MapSet.to_list(to_split),
            reduce: {0, continue} do
          {s, b} -> {s+1, b |> MapSet.put(beam-1) |> MapSet.put(beam+1)}
        end
        {splitted + split, MapSet.union(continue, new_beams)}
      end
    end
  end
end

file = "aoc-7-input.txt"
File.stream!(file)
|> Stream.map(&String.trim(&1) |> then(fn res -> String.codepoints(res) end))
|> Enum.to_list()
|> Enum.reduce({0, MapSet.new()}, fn line, {splitted, beams} -> Beams.split(line, beams, splitted) end)
|> then(fn {splitted,_} -> IO.puts("#{splitted}") end)
