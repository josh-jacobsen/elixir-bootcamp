defmodule Weather.View do
  @moduledoc "Functions for getting user input and rendering application output"

  # TODO: Add error handling messaging
  # TODO: Validation
  @spec display_weather_at_location(%{conditions: String.t(), temp: String.t()}, String.t()) ::
          :ok
  def display_weather_at_location(%{conditions: conditions, temp: temp}, location) do
    IO.puts(
      "The weather in #{String.capitalize(location)} is currently #{conditions} and the temperature is #{temp} degrees"
    )
  end

  def prompt_user_for_location() do
    user_input = IO.gets("What location would you like the weather for? ")

    user_input
    |> String.trim()
    |> String.downcase()
  end

  def display_error(reason) do
    case reason do
      :http_error ->
        IO.puts("The operation failed due to an HTTP error. Please check the input and try again")

      :unexpected_format ->
        IO.puts("The body of the response was in an unexpected format")

      _ ->
        IO.puts("The operation failed. Please check the input and try again")
    end
  end
end
