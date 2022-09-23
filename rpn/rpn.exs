#  2 4 * 8 + => 16
#  2 4 8 + * => 24
#  3 2 * 11 - => -5
#  2 5 * 4 + 3 2 * 1 + / => 2

defmodule RPN do
  def run() do
    IO.puts("Running reduce while")

    IO.gets("Enter your calculation: ")
    |> String.trim()
    |> String.split(" ", trim: true)
    |> convert_from_string()
    |> calculate_reduce_while()
    |> case do
      {:error, :stack_underflow} ->
        IO.puts("The number of operators exceeds numbers on the stack")

      [result] ->
        IO.inspect(result)
    end
  end

  def convert_from_string(input) do
    Enum.map(input, fn value ->
      case Integer.parse(value) do
        {number, ""} -> number
        _ -> String.to_atom(value)
      end
    end)
  end

  def calculate_reduce_while(input) do
    Enum.reduce_while(input, [], fn token, stack ->
      cond do
        is_integer(token) ->
          {:cont, [token | stack]}

        is_atom(token) ->
          case stack do
            [value_2, value_1 | tail] ->
              {:cont, [apply_arguments(value_1, value_2, token) | tail]}

            _ ->
              {:halt, {:error, :stack_underflow}}
          end
      end
    end)
  end

  def run_recursive() do
    IO.puts("Running recursive")

    IO.gets("Enter your calculation: ")
    |> String.trim()
    |> String.split(" ", trim: true)
    |> convert_from_string()
    |> calculate_recursive([])
    |> IO.inspect()
  end

  def calculate_recursive([], [result]) do
    result
  end

  def calculate_recursive([token | remaining_input], stack) when is_integer(token) do
    calculate_recursive(remaining_input, [token | stack])
  end

  def calculate_recursive([token | remaining_input], [value_2, value_1 | tail])
      when is_atom(token) do
    result = apply_arguments(value_1, value_2, token)
    calculate_recursive(remaining_input, [result | tail])
  end

  def apply_arguments(a, b, operator) when operator in [:+, :-, :*, :/] do
    apply(Kernel, operator, [a, b])
  end
end

RPN.run_recursive()

# def calculate_reduce(input) do
#   # Enum.reduce_while
#   # Recursion
#   Enum.reduce(input, [], fn token, stack ->
#     cond do
#       is_integer(token) ->
#         [token | stack]

#       is_atom(token) ->
#         # Return {:error, reason} if not 2 values on stack
#         [value_2, value_1 | tail] = stack
#         [apply_arguments(value_1, value_2, token) | tail]
#     end
#   end)
# end

# def calculate_recursive([token | remaining_input], stack) do
#   cond do
#     is_integer(token) ->
#       calculate_recursive(remaining_input, [token | stack])

#     is_atom(token) ->
#       [value_2, value_1 | tail] = stack
#       result = apply_arguments(value_1, value_2, token)
#       calculate_recursive(remaining_input, [result | tail])
#   end
# end
