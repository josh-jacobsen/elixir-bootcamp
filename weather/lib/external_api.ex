defmodule Weather.ExternalAPI do
  alias Finch.Response
  alias Finch.Request

  @behaviour Weather.ExternalAPIBehaviour

  def child_spec do
    {
      Finch,
      name: __MODULE__
    }
  end

  # @spec request(Request.t()) :: {:ok, result :: Response} | {:error, reason :: term}
  def make_request(request) do
    http_client = Application.get_env(:weather, :http_client, Finch)
    http_client.request(request, __MODULE__)
  end

  @spec get_current_weather_for_location(String.t()) :: String.t()
  def get_current_weather_for_location(location) do
    get_weather_report(location)
    |> extract_current_conditions()
  end

  defp get_weather_report(location) do
    api_key = Application.fetch_env!(:weather, :api_key)

    :get
    |> Finch.build(
      "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/#{location}?unitGroup=metric&key=#{api_key}&contentType=json"
    )
    |> make_request()
  end

  # @spec extract_current_conditions({:error, _}) :: String.t()
  defp extract_current_conditions({:error, _}) do
    ":("
  end

  # @spec extract_current_conditions({:ok, Response}) :: String.t()
  defp extract_current_conditions({:ok, %Response{body: body}}) do
    body
    |> Jason.decode!()
    |> case do
      # TODO: Error handling
      %{"currentConditions" => %{"conditions" => conditions, "temp" => temp}} ->
        %{conditions: String.downcase(conditions), temp: temp}

      _ ->
        ""
    end
  end
end
