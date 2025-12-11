defmodule Reactor do
  def count_paths(paths) do
    create_map(paths)
    |> do_count_paths("you", "out")
  end

  defp do_count_paths(map, from, to, visited \\ MapSet.new()) do
    if from == to do
      1
    else
      Map.get(map, from, [])
      |> Enum.filter(fn node -> not MapSet.member?(visited, node) end)
      |> Enum.reduce(0, fn node, acc ->
        acc + do_count_paths(map, node, to, MapSet.put(visited, from))
      end)
    end
  end

  defp create_map(paths) do
    Enum.reduce(paths, %{}, fn [<<path_from::binary-size(3),":">> | path_to], acc ->
      Map.put(acc, path_from, path_to)
    end)
  end
end

file = "aoc-11-input.txt"
File.stream!(file)
|> Stream.map(&String.trim(&1)
              |> then(fn str -> String.split(str, " ") end))
|> Enum.to_list()
|> then(fn paths -> Reactor.count_paths(paths) end)
|> then(fn code -> IO.puts("#{code}") end)
