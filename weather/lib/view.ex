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
end
