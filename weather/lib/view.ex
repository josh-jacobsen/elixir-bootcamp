defmodule Weather.View do
  @moduledoc "Functions for getting user input and rendering application output"

  def prompt_user_for_location() do
    user_input = prompt_user_for_input()

    case validate_input(user_input) do
      :ok ->
        user_input

      {:error, reason} ->
        display_error(reason)
        prompt_user_for_location()
    end
  end

  defp prompt_user_for_input() do
    IO.gets("What location would you like the weather for? ")
    |> String.trim()
    |> String.downcase()
  end

  defp validate_input(user_input) do
    validate_input_length(String.length(user_input))
  end

  defp validate_input_length(input) when input > 1 do
    :ok
  end

  defp validate_input_length(_) do
    {:error, :input_too_short}
  end

  def display_error(reason) do
    case reason do
      :http_error ->
        IO.puts("The operation failed due to an HTTP error")

      :unexpected_format ->
        IO.puts(
          "The body of the response was in an unexpected format which means the location is likely invalid. Please check the input and try again"
        )

      :input_too_short ->
        IO.puts("That is not a valid location. Please check the input and try again")

      _ ->
        IO.puts("The operation failed. Please check the input and try again")
    end
  end

  @spec display_weather_at_location(%{conditions: String.t(), temp: String.t()}, String.t()) ::
          :ok
  def display_weather_at_location(%{conditions: conditions, temp: temp}, location) do
    IO.puts(
      "The weather in #{String.capitalize(location)} is currently #{conditions} and the temperature is #{temp} degrees"
    )
  end
end
