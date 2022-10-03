defmodule WeatherTest do
  use ExUnit.Case

  test "gets weather for Takapuna" do
    assert Weather.APIClient.get_current_weather_for_location("tapakuna") == "clear"
  end
end
