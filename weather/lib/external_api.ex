defmodule Weather.ExternalAPI do
  alias Finch.Response

  #  Make behaviour that takes request and returns response

  def child_spec do
    {
      Finch,
      name: __MODULE__
    }
  end

  # Wrap in function
  #  get_env, default to finch, finch mock with 1 function (request)
  defp request(request) do
    IO.inspect(request, label: "Request")
    # finch = Application.get_env(:my_app, :http_client)
    # finch.request(request, __MODULE__)
    http_client = Application.get_env(:weather, :http_client, Finch)

    http_client.request(request, __MODULE__)
  end

  defp get_weather_report(location) do
    api_key = Application.fetch_env!(:weather, :api_key)

    :get
    |> Finch.build(
      "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/#{location}?unitGroup=metric&key=#{api_key}&contentType=json"
    )
    |> request()
  end

  defp extract_current_conditions({:ok, %Response{body: body}}) do
    body
    |> Jason.decode!()
    |> case do
      # TODO: Error handling
      %{"currentConditions" => %{"conditions" => conditions}} -> String.downcase(conditions)
      _ -> ""
    end
  end

  def get_current_weather_for_location(location) do
    get_weather_report(location)
    |> extract_current_conditions()
  end
end
