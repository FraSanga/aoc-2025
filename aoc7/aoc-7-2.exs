defmodule Beam do
  def enters([[beam] | lines]),
    do: timelines(lines, beam, Map.new(), 1)

  defp timelines([], beam, cache, index), do: {1, Map.put(cache, "#{index}/#{beam}", 1)}
  defp timelines([line | lines], beam, cache, index) do
    if beam not in line do
      case Map.get(cache, "#{index+1}/#{beam}", nil) do
        nil -> timelines(lines, beam, cache, index+1)
        val -> {val, cache}
      end
    else
      {l, _} = case Map.get(cache, "#{index+1}/#{beam-1}", nil) do
        nil -> timelines(lines, beam-1, cache, index+1)
        val -> {val, cache}
      end

      {r, _} = case Map.get(cache, "#{index+1}/#{beam+1}", nil) do
        nil -> timelines(lines, beam+1, cache, index+1)
        val -> {val, cache}
      end

      {l+r, Map.put(cache, "#{index}/#{beam}", l+r)}
    end

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
|> then(fn {code, _ } -> IO.puts("#{code}") end)
