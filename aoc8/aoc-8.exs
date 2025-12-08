defmodule Boxes do
  @to_connect 1000

  def connect(map, points) do
    candidates = search_candidates(map, points, [])
    do_connect(map, candidates, @to_connect, [], [])
    |> Enum.sort_by( &(length(&1)), :desc)
    |> Enum.take(3)
    |> Enum.map(fn circuits -> length(circuits) end)
    |> Enum.product()
  end

  defp do_connect(_, _, 0, _, connected), do: connected
  defp do_connect(map, candidates, count, visited, connected) do
    {{a, b, _}, remaining} = pick_min_distance(candidates)
    {new_visited, new_connected} = cond do
      a not in visited and b not in visited -> {[a,b] ++ visited, create_circuit(a, b, connected)}
      a not in visited and b in visited -> {[a | visited], add_to_circuit(a, b, connected)}
      a in visited and b not in visited -> {[b | visited], add_to_circuit(b, a, connected)}
      a in visited and b in visited -> {visited, union_circuit(a, b, connected)}
    end
    new_map = update_map(map, a) |> update_map(b)
    new_candidates = search_candidates(new_map, [a,b], remaining)
    do_connect(new_map, new_candidates, count - 1, new_visited, new_connected)
  end

  defp pick_min_distance(candidates) do
    min = Enum.min_by(candidates, fn {_, _, distance} -> distance end)
    {min, candidates -- [min]}
  end

  defp update_map(map, a) do
    Map.update!(map, a, fn {point, _, connected} -> min_distance(a, Map.keys(map) -- [a], [point | connected]) end)
  end

  defp create_circuit(a, b, connected), do: [[a,b] | connected]
  defp add_to_circuit(a, to_b, connected) do
    {circuit, remaining} = find_circuit(to_b, connected)
    [[a | circuit] | remaining]
  end
  defp union_circuit(a, b, connected) do
    {circuit_a, remaining} = find_circuit(a, connected)
    case find_circuit(b, remaining) do
      {_, ^remaining} -> connected
      {circuit_b, rest} -> [circuit_a ++ circuit_b | rest]
    end
  end
  defp find_circuit(x, circuits) do
    index = Enum.find_index(circuits, fn points -> x in points end)
    if index != nil, do: List.pop_at(circuits, index), else: {nil, circuits}
  end

  defp search_candidates(_, [], candidates), do: candidates
  defp search_candidates(map, [point | points], candidates) do
    {next, distance, _} = Map.get(map, point)
    case Map.get(map, next) do
      {^point, _, _} -> search_candidates(map, points -- [next], [{point, next, distance} | candidates])
      {_, _, _} -> search_candidates(map, points, candidates)
    end
  end

  def min_distance(point, points, connected \\ [])
  def min_distance(point, points, connected) do
    do_min_distance(point, points, connected, nil)
  end

  defp do_min_distance(_, [], connected, {min, min_distance}), do: {min, min_distance, connected}
  defp do_min_distance(point, [to_check | points], connected, nil) do
    if to_check in connected do
      do_min_distance(point, points, connected, nil)
    else
      do_min_distance(point, points, connected, {to_check, distance(point, to_check)})
    end
  end
  defp do_min_distance(point, [to_check | points], connected, {min, min_distance}) do
    if to_check in connected do
      do_min_distance(point, points, connected, {min, min_distance})
    else
      distance = distance(point, to_check)
      if distance < min_distance do
        do_min_distance(point, points, connected, {to_check, distance})
      else
        do_min_distance(point, points, connected, {min, min_distance})
      end
    end
  end

  defp distance(a, b) do
    [x_a,y_a,z_a] = String.split(a, ",")
    [x_b,y_b,z_b] = String.split(b, ",")
    :math.pow(String.to_integer(x_a) - String.to_integer(x_b), 2) +
    :math.pow(String.to_integer(y_a) - String.to_integer(y_b), 2) +
    :math.pow(String.to_integer(z_a) - String.to_integer(z_b), 2) |> :math.sqrt()
  end
end


file = "aoc-8-input.txt"
points = File.stream!(file)
|> Stream.map(&String.trim/1)
|> Enum.to_list()

Map.new(points, fn point -> {point, Boxes.min_distance(point, points -- [point], [])} end)
|> then(fn map -> Boxes.connect(map, points) end)
|> then(fn code -> IO.puts("#{code}") end)
