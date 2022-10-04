defmodule Weather.ExternalAPI do
  alias Finch.Response
  alias Finch.Request

  @behaviour Weather.ExternalAPIBehaviour

  #  Make behaviour that takes request and returns response
  # @callback request(Request.t()) :: {:ok, result :: Response} | {:error, reason :: term}

  def child_spec do
    {
      Finch,
      name: __MODULE__
    }
  end

  def request(request) do
    http_client = Application.get_env(:weather, :http_client, Finch)

    http_client.request(request, __MODULE__)
  end

  def get_current_weather_for_location(location) do
    get_weather_report(location)
    |> extract_current_conditions()
  end

  defp get_weather_report(location) do
    api_key = Application.fetch_env!(:weather, :api_key)

    finchRequest =
      :get
      |> Finch.build(
        "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/#{location}?unitGroup=metric&key=#{api_key}&contentType=json"
      )

    IO.inspect(finchRequest, label: "Finch request")

    result = request(finchRequest)

    IO.inspect(result, label: "result from API call")
    result
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
end
