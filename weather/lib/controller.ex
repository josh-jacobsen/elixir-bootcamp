defmodule Weather.Controller do
  alias Weather.{View, ExternalAPI}

  @one_second 1000

  @initial_state %{
    location: nil
  }

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    # TODO: Move to View and add validation
    user_input = IO.gets("What location would you like the weather for? ")

    location =
      String.trim(user_input)
      |> String.downcase()

    Process.send_after(self(), :tick, @one_second)

    {:ok, %{state | location: location}}
  end

  def handle_info(:tick, state) do
    weather = ExternalAPI.get_current_weather_for_location(state.location)
    View.display_weather_at_location(weather, state.location)

    Process.send_after(self(), :tick, @one_second)

    {:noreply, state}
  end
end
