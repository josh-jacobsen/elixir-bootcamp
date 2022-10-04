defmodule WeatherTest do
  use ExUnit.Case, async: true
  import Mox
  setup :verify_on_exit!

  test "extracts conditions and temperature on 200 response" do
    expect(ExternalApiBehaviourMock, :request, fn arg1, arg2 ->
      {:ok,
       %Finch.Response{
         status: 200,
         body:
           "{ \"currentConditions\": { \"temp\": 15.6, \"conditions\": \"Rain, Partially cloudy\" }}"
       }}
    end)

    assert Weather.ExternalAPI.get_current_weather_for_location("tapakuna") ==
             %{conditions: "rain, partially cloudy", temp: 15.6}
  end
end
