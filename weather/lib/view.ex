defmodule Weather.View do
  def display_weather_at_location(weather, location) do
    IO.puts("The weather in #{String.capitalize(location)} is currently #{weather}")
  end

  def countdown_to_getting_weather(location, count) do
    IO.puts("Getting weather for #{String.capitalize(location)} in #{count} seconds..")
  end

  def getting_weather(location) do
    IO.puts("Getting weather for #{String.capitalize(location)}..")
  end

  def hello() do
    :world
  end
end
