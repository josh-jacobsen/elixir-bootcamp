defmodule Weather.Controller do
  @moduledoc """
  Main controller for the application. On start up it will prompt the user for the location for which to get the weather
  and then display the results
  """

  alias Weather.{View, APIClient}

  @interval_in_milliseconds 1000

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

    Process.send_after(self(), :tick, @interval_in_milliseconds)

    {:ok, %{state | location: location}}
  end

  @impl true
  def handle_info(:tick, state) do
    # TODO: levels of abstraction (refactor into handler function and calling function)
    #  dont use get in function name

    # extract these into function
    case APIClient.get_current_weather_for_location(state.location) do
      {:ok, weather} -> View.display_weather_at_location(weather, state.location)
      {:error, reason} -> View.display_error(reason)
    end

    # Extract into different function thats also called from L26
    Process.send_after(self(), :tick, @interval_in_milliseconds)

    {:noreply, state}
  end
end
