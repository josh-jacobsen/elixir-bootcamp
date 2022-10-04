defmodule Weather.View do
  def display_weather_at_location(%{conditions: conditions, temp: temp}, location) do
    IO.puts(
      "The weather in #{String.capitalize(location)} is currently #{conditions} and the temperature is #{temp} degrees"
    )
  end
end
