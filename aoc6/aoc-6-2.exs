defmodule Problems do

  def eval(group, {nil, {total, 0}}) do
    {number, op} = Tuple.to_list(group) |> do_eval("")
    {op, {total, number}}
  end
  def eval(group, {"*", {total, acc}}) do
    case Tuple.to_list(group) |> do_eval("") do
      {nil, nil} -> {nil, {total + acc, 0}}
      {number, nil} -> {"*", {total, acc * number}}
    end
  end
  def eval(group, {"+", {total, acc}}) do
    case Tuple.to_list(group) |> do_eval("") do
      {nil, nil} -> {nil, {total + acc, 0}}
      {number, nil} -> {"+", {total, acc + number}}
    end
  end


  defp do_eval([" " | []], ""), do: {nil, nil}
  defp do_eval([" " | []], number), do: {String.to_integer(number), nil}
  defp do_eval(["*" | []], number), do: {String.to_integer(number), "*"}
  defp do_eval(["+" | []], number), do: {String.to_integer(number), "+"}
  defp do_eval([" " | rest], number), do: do_eval(rest, number)
  defp do_eval([n | rest], number), do: do_eval(rest, number <> n)
end

file = "aoc-6-input.txt"
File.stream!(file)
|> Stream.map(&String.split(&1, "\n") |> then(fn res -> List.first(res) |> String.codepoints() end))
|> Stream.zip()
|> Enum.to_list()
|> Enum.reduce({nil, {0, 0}}, fn group, acc -> Problems.eval(group, acc) end)
|> then(fn {_, {total, acc}} -> IO.puts("#{total + acc}") end)
