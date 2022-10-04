defmodule WeatherTest do
  use ExUnit.Case, async: true
  import Mox
  setup :verify_on_exit!

  test ":ok on 200" do
    expect(ExternalApiBehaviourMock, :request, fn args ->
      IO.inspect(args, label: "args from test")
      {:ok, %Finch.Response{status: 200}}
    end)

    result = Weather.ExternalAPI.get_current_weather_for_location("tapakuna")

    IO.inspect(result)
  end
end
