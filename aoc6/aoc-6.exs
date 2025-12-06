defmodule Problems do
  def eval(group), do: Tuple.to_list(group) |> do_eval([])

  defp do_eval(["*" | []], acc), do: Enum.product(acc)
  defp do_eval(["+" | []], acc), do: Enum.sum(acc)
  defp do_eval([n | rest], acc), do: do_eval(rest, [String.to_integer(n) | acc])
end

file = "aoc-6-input.txt"
File.stream!(file)
|> Stream.map(&String.split/1)
|> Stream.zip()
|> Enum.to_list()
|> Enum.reduce(0, fn group, acc -> Problems.eval(group) + acc end)
|> then(fn code -> IO.puts("#{code}") end)
