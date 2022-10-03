defmodule Weather.Controller do
  alias Weather.{View, ExternalAPI}

  @one_second 1000
  @count 0

  @initial_state %{
    location: nil,
    count: @count
  }

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def hello() do
    :world
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

  def handle_info(:tick, %{count: 0} = state) do
    View.getting_weather(state.location)

    weather = ExternalAPI.get_current_weather_for_location(state.location)
    View.display_weather_at_location(weather, state.location)

    Process.send_after(self(), :tick, @one_second)

    {:noreply, %{state | count: 10}}
  end

  def handle_info(:tick, state) do
    View.countdown_to_getting_weather(state.location, state.count)

    Process.send_after(self(), :tick, @one_second)

    current_count = state.count
    {:noreply, %{state | count: current_count - 1}}
  end
end
