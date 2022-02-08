defmodule ElixirWorker do
  require Logger
  use Application

  def start(_, _) do
    IO.puts("Starting Elixir/Erlang worker")

    children = [
      ElixirWorker.Listener
    ]

    opts = [strategy: :one_for_one, name: ElixirWorker.Supervisor]

    spawn(fn ->
      :timer.sleep(30000)
      IO.puts("forcing an exit")
      System.halt()
    end)

    Supervisor.start_link(children, opts)
  end
end
