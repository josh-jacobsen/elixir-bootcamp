defmodule Weather.Server do
  @ten_seconds 10000
  @one_seconds 1000

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(state) do
    IO.puts("Genserverr running")
    city = IO.gets("What city do you want to look at?")
    IO.puts(city)
    Process.send_after(self(), :tick, @ten_seconds)
    Process.send_after(self(), :tick2, @one_seconds)

    {:ok, state}
  end

  def handle_info(:tick, state) do
    time =
      DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.to_iso8601()

    IO.puts("The time is now: #{time}")

    Process.send_after(self(), :tick, @ten_seconds)

    {:noreply, state}
  end

  def handle_info(:tick2, state) do
    time =
      DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.to_iso8601()

    IO.puts("The time is now: #{time}")

    Process.send_after(self(), :tick2, @one_seconds)

    {:noreply, state}
  end
end
