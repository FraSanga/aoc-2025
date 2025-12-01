defmodule Dial do
  def unlock("R"<>rest, pos) do
    number = rem(String.to_integer(rest), 100)
    rem(pos + number, 100)
  end
  def unlock("L"<>rest, pos) do
    number = rem(String.to_integer(rest), 100)
    if number > pos, do: 100 - (number - pos), else: pos - number
  end
end


file = "aoc-1-input.txt"
#file = "test.txt"
File.stream!(file)
|> Stream.map(&String.trim/1)
|> Stream.transform(50, fn move, pos ->
  new_pos = Dial.unlock(move, pos)
  {[new_pos], new_pos}
end)
|> Enum.to_list()
|> Enum.reduce(0, fn pos, acc -> if pos == 0, do: acc + 1, else: acc end)
|> then(fn code ->IO.puts("#{code}") end)
