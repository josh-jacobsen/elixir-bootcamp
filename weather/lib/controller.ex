defmodule Weather.Controller do
  @moduledoc """
  Main controller for the application. On start up it will prompt the user for the location for which to get the weather
  and then display the results
  """

  alias Weather.{View, APIClient}

  @interval_in_milliseconds 1000
  @weather_callback_signature :weather

  @initial_state %{
    location: nil
  }

  use GenServer

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    location = View.prompt_user_for_location()

    reschedule_callback(@weather_callback_signature, @interval_in_milliseconds)

    {:ok, %{state | location: location}}
  end

  @impl true
  def handle_info(:weather, state) do
    handle_weather_request(state.location)
    reschedule_callback(@weather_callback_signature, @interval_in_milliseconds)
    {:noreply, state}
  end

  defp reschedule_callback(weather_callback_signature, interval) do
    Process.send_after(self(), weather_callback_signature, interval)
  end

  defp handle_weather_request(location) do
    case APIClient.get_current_weather_for_location(location) do
      {:ok, weather} -> View.display_weather_at_location(weather, location)
      {:error, reason} -> View.display_error(reason)
    end
  end
end
