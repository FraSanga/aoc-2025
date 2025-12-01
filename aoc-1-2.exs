defmodule Dial do
  def unlock("R"<>rest, pos) do
    {number, rotations} = format_number(rest) |> dbg()
    {rem(pos + number, 100), rotations + div(pos + number, 100)}
  end
  def unlock("L"<>rest, pos) do
    {number, rotations} = format_number(rest) |> dbg()
    if number > pos, do: {100 - (number - pos), rotations + 1}, else: {pos - number, rotations}
  end
  defp format_number(rest) do
    number = String.to_integer(rest)
    {rem(number, 100), div(number, 100)}
  end
end


#file = "aoc-1-input.txt"
file = "test.txt"
File.stream!(file)
|> Stream.map(&String.trim/1)
|> Stream.transform(50, fn move, pos ->
  {new_pos, rotations} = Dial.unlock(move, pos)
  {[{new_pos, rotations}], new_pos}
end)
|> Enum.to_list() |> dbg()
|> Enum.reduce(0, fn {pos, rotations}, acc -> if pos == 0, do: rotations + acc + 1, else: rotations + acc end)
|> then(fn code ->IO.puts("#{code}") end)
