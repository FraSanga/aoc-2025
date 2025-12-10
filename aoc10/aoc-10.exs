defmodule Machine do
  def configure([diagram_str | instructions]) do
    {diagram, d_size} = configure_diagram(diagram_str) |> dbg()
    buttons = configure_instructions(instructions, d_size, []) |> dbg()
    do_configure(diagram, buttons, 0, :infinity) |> dbg()
  end

  defp do_configure(diagram, [], pressed, _) do
    if lights_off?(diagram), do: pressed
  end
  defp do_configure(diagram, buttons, pressed, min_found) when min_found > pressed do
    if lights_off?(diagram) do
      pressed
    else
      Enum.reduce(buttons, min_found, fn button, min ->
        new_min = press_button(diagram, button)
        |> do_configure(List.delete(buttons, button), pressed + 1, min)
        min(new_min, min)
      end)
    end
  end
  defp do_configure(_, _, _, _), do: nil

  defp press_button(<<bit, diagram::binary>>, <<"1", button::binary>>) do
    <<inverse_bit(bit), press_button(diagram, button)::binary>>
  end
  defp press_button(<<bit, diagram::binary>>, <<"0", button::binary>>) do
    <<bit, press_button(diagram, button)::binary>>
  end
  defp press_button(<<>>, <<>>), do: <<>>

  defp inverse_bit(?0), do: ?1
  defp inverse_bit(?1), do: ?0

  defp lights_off?(<<"0", rest::binary>>), do: lights_off?(rest)
  defp lights_off?(<<"1", _rest::binary>>), do: false
  defp lights_off?(<<>>), do: true

  defp configure_diagram(diagram_str) do
    diagram_str
    |> String.slice(1..-2//1)
    |> String.replace(".", "0")
    |> String.replace("#", "1")
    |> then(fn diagram -> {diagram, String.length(diagram)} end)
  end

  defp configure_instructions([_ | []], _, buttons), do: buttons
  defp configure_instructions([button | rest], size, buttons) do
    configure_instructions(rest, size, [configure_button(button, size) | buttons])
  end

  defp configure_button(button_str, size) do
    button_str
    |> String.slice(1..-2//1)
    |> String.split(",")
    |> Enum.reduce(String.duplicate("0", size), fn pos_str, acc ->
      pos = String.to_integer(pos_str)
      binary_slice(acc, 0, pos) <> "1" <> binary_slice(acc, pos+1, size-pos)
    end)
  end
end

file = "aoc-10-input.txt"
File.stream!(file)
|> Stream.map(&String.trim(&1)
              |> then(fn str -> String.split(str, " ") end))
|> Enum.to_list()
|> Enum.reduce(0, fn line, acc -> acc + Machine.configure(line) end)
|> then(fn code -> IO.puts("#{code}") end)
