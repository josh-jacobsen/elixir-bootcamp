defmodule WeatherTest do
  use ExUnit.Case, async: true
  import Mox
  setup :verify_on_exit!

  test "Extracts conditions and temperature from response" do
    expect(ExternalApiBehaviourMock, :request, fn _, _ ->
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

  test "Handles error from API" do
    expect(ExternalApiBehaviourMock, :request, fn _, _ ->
      {:error, "uh oh, spagetti ohs"}
    end)

    assert Weather.ExternalAPI.get_current_weather_for_location("tapakuna") ==
             {:error, "uh oh, spagetti ohs"}
  end

  test "Handles missing temperature data" do
    expect(ExternalApiBehaviourMock, :request, fn _, _ ->
      {:ok,
       %Finch.Response{
         status: 200,
         body: "{ \"currentConditions\": { \"conditions\": \"Rain, Partially cloudy\" }}"
       }}
    end)

    assert Weather.ExternalAPI.get_current_weather_for_location("tapakuna") ==
             {:error, "Message body did not match expected format"}
  end
end
