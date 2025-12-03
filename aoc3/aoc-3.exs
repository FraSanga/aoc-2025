defmodule Battery do
  def find_max_joltage(_, 0, acc) do
    Enum.reverse(acc) |> Enum.join() |> String.to_integer()
  end
  def find_max_joltage(bank, to_find, acc) when to_find > 0 do
    len = String.length(bank)
    {max, index} = for i <- 0..(len-to_find),
        joltage = String.at(bank,i),
        reduce: {0,-1} do
      {max_joltage,j} -> if max_joltage < joltage, do: {joltage,i}, else: {max_joltage,j}
    end
    find_max_joltage(String.slice(bank,index+1..-1//1), to_find-1, [max | acc])
  end
end

to_find = 12
file = "aoc-3-input.txt"
File.stream!(file)
|> Stream.map(
  fn bank -> Battery.find_max_joltage(String.trim(bank), to_find, []) end
)
|> Enum.to_list()
|> Enum.sum()
|> then(fn code ->IO.puts("#{code}") end)
