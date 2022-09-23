defmodule VariableTracker do
  def start() do
    spawn(fn -> loop(nil) end)
  end

  def loop(variable) do
    receive do
      {:store, value} ->
        loop(value)

      # code
      {:get, sender_pid} ->
        send(sender_pid, {:variable, variable})
        loop(variable)
    end
  end

  def store(destination_pid, variable) do
    send(destination_pid, {:store, variable})
    :ok
  end

  def get(destination_pid) do
    send(destination_pid, {:get, self()})

    receive do
      {:variable, variable} -> variable
    end
  end
end
