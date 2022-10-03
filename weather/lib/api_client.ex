defmodule Weather.APIClient do
  alias Weather.ExternalAPI

  def get_current_weather_for_location(location) do
    ExternalAPI.get_current_weather_for_location(location)
  end
end
