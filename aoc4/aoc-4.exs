defmodule Rolls do
  @neighbor_offsets [
    {-1, -1}, {-1, 0}, {-1, 1},
    {0, -1},          {0, 1},
    {1, -1},  {1, 0}, {1, 1}
  ]

  def access(map, max_neighbors) do
    rows = length(map)
    cols = length(Enum.at(map, 0) |> then(fn {rows, _} -> rows end))
    Enum.reduce(map, 0, fn {row, row_index}, acc ->
      Enum.reduce(row, acc, fn {col_index, cell}, count ->
        if cell == "@" and count_neighbors(map, row_index, col_index, {rows, cols}) <= max_neighbors do
          count + 1
        else
          count
        end
      end)
    end)
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
|> Rolls.access(3)
|> then(fn code -> IO.puts("#{code}") end)
