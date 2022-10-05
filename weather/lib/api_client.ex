defmodule Weather.APIClient do
  @moduledoc """
  Encapsulates the external API that provides the weather data
  """
  alias Finch.{Response}

  @base_url "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/"

  @spec get_current_weather_for_location(String.t()) ::
          {:ok, %{conditions: String.t(), temp: String.t()}} | {:error, reason :: term()}
  def get_current_weather_for_location(location) do
    fetch_weather_report(location)
    |> extract_current_conditions()
  end

  defp fetch_weather_report(location) do
    params = %{
      unitGroup: "metric",
      contentType: "json",
      key: api_key()
    }

    Finch.build(:get, "#{@base_url}#{URI.encode(location)}?#{URI.encode_query(params)}")
    |> request()
  end

  defp api_key(), do: Application.fetch_env!(:weather, :api_key)

  defp request(request) do
    http_client = Application.get_env(:weather, :http_client, Finch)
    http_client.request(request, Weather.Finch)
  end

  defp extract_current_conditions({:ok, %Response{body: body}}) do
    body
    |> Jason.decode()
    |> case do
      {:ok, %{"currentConditions" => %{"conditions" => conditions, "temp" => temp}}} ->
        {:ok, %{conditions: String.downcase(conditions), temp: temp}}

      _ ->
        {:error, :unexpected_format}
    end
  end

  defp extract_current_conditions({:error, _reason}) do
    {:error, :http_error}
  end
end
