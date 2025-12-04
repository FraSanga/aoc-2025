defmodule Rolls do
  @neighbor_offsets [
    {-1, -1}, {-1, 0}, {-1, 1},
    {0, -1},          {0, 1},
    {1, -1},  {1, 0}, {1, 1}
  ]

  def access(map, max_neighbors, count) do
    rows = length(map)
    cols = length(Enum.at(map, 0) |> then(fn {rows, _} -> rows end))
    rols_to_remove = Enum.reduce(map, [], fn {row, row_index}, acc ->
      Enum.reduce(row, acc, fn {col_index, cell}, rols_to_remove ->
        if cell == "@" and count_neighbors(map, row_index, col_index, {rows, cols}) <= max_neighbors do
          [{row_index, col_index} | rols_to_remove]
        else
          rols_to_remove
        end
      end)
    end)
    count_rolls = length(rols_to_remove)
    if count_rolls > 0,
      do: remove_rolls(map, rols_to_remove) |> access(max_neighbors, count + count_rolls),
      else: count
  end

  defp remove_rolls(map, []), do: map
  defp remove_rolls(map, [{row_index, col_index} | rest]) do
    updated_map = List.update_at(map, row_index, fn {row, index} ->
      {
        List.update_at(row, col_index, fn {_col_index, _cell} -> {col_index, "."} end),
        index
      }
    end)
    remove_rolls(updated_map, rest)
  end

  defp count_neighbors(map, row, col, {rows, cols}) do
    Enum.reduce(@neighbor_offsets, 0, fn {dx, dy}, count ->
      neighbor_row = row + dx
      neighbor_col = col + dy

      if valid_position?(neighbor_row, neighbor_col, rows, cols) and
         Enum.at(Enum.at(map, neighbor_row) |> then(fn {rows, _} -> rows end), neighbor_col) |> then(fn {_, cell} -> cell end) == "@" do
        count + 1
      else
        count
      end
    end)
  end

  defp valid_position?(row, col, rows, cols) do
    row >= 0 and row < rows and col >= 0 and col < cols
  end
end

file = "aoc-4-input.txt"
File.stream!(file)
|> Stream.map(
  fn string -> String.trim(string) |> String.codepoints() |> Enum.with_index(fn v,k -> {k,v} end) end
)
|> Stream.with_index()
|> Enum.to_list()
|> Rolls.access(3, 0)
|> then(fn code -> IO.puts("#{code}") end)
