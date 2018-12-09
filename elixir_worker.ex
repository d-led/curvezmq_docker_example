defmodule ElixirWorker do
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(args) do
    # listen to chumak crashes
    Process.flag(:trap_exit, true)

    # switch to listening to zmq
    Process.send_after(self(), :start_listening, 100)

    # stop after some time
    Process.send_after(self(), :stop_application, 10000)

    {:ok, args}
  end

  def handle_info(:start_listening, state) do
    {:ok, pull} = :chumak.socket(:pull)
    :chumak.connect(pull, :tcp, 'go-server', 7777)

    {:ok, push} = :chumak.socket(:push)
    :chumak.connect(push, :tcp, 'go-server', 7778)
    listen({pull,push})
    {:noreply, state}
  end

  def handle_info(:stop_application, state) do
    {:stop, state}
  end

  def handle_info(whatever, _state) do
    IO.inspect(whatever)
    {:stop, "shutting down ..."}
  end

  def listen({pull, push}) do
    case :chumak.recv(pull) do
      {:ok, body} ->
        Logger.info body
        listen({pull, push})
      err ->
        IO.puts "Shutting down Elixir worker: #{err}"
    end
  end

  # defp hello do
  #   IO.inspect File.read!(Path.join(:code.priv_dir(:elixir_worker), "client.key"))
  # end
end
