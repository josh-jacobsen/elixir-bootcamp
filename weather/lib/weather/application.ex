defmodule Weather.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {Finch, name: Weather.Finch}
      ]
      |> add_server()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Weather.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp add_server(children) do
    if start_server?() do
      [Weather.Controller | children]
    else
      children
    end
  end

  defp start_server?() do
    Application.get_env(:weather, :server, true)
  end
end
