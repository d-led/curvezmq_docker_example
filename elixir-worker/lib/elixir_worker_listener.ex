defmodule ElixirWorker.Listener do
  require Logger
  use GenServer

  @server_key Path.join(:code.priv_dir(:elixir_worker), "server.key")
  @client_key Path.join(:code.priv_dir(:elixir_worker), "client.key_secret")

  # GenServer init

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  #
  def init(_) do
    # connect after a while to not block the startup
    Process.send_after(self(), :start, 3000)
    {:ok, nil}
  end

  # GenServer callbacks

  def handle_info(:start, _) do
    start()
    {:noreply, nil}
  end

  # implementation

  def start() do
    IO.puts("Server key file: #{@server_key}")
    IO.puts("Client key file: #{@client_key}")
    IO.puts("Worker process: #{inspect(self())}")
    {:ok, [public_key: server_public]} = :chumak_cert.read(@server_key)
    {:ok, [public_key: client_public, secret_key: client_secret]} = :chumak_cert.read(@client_key)

    {:ok, pull} = :chumak.socket(:pull)
    :ok = :chumak.set_socket_option(pull, :curve_server, false)
    :ok = :chumak.set_socket_option(pull, :curve_serverkey, server_public)
    :ok = :chumak.set_socket_option(pull, :curve_secretkey, client_secret)
    :ok = :chumak.set_socket_option(pull, :curve_publickey, client_public)

    pony_server = String.to_charlist(System.get_env("PONY_SERVER", "pony-server"))

    # 2nd argument: not a tuple
    # {:ok, _peer_id} = :chumak.connect(pull, :tcp, pony_server, 7777)

    IO.puts("Pull socket: #{inspect(pull)}")

    {:ok, push} = :chumak.socket(:push)
    :ok = :chumak.set_socket_option(push, :curve_server, false)
    :ok = :chumak.set_socket_option(push, :curve_serverkey, server_public)
    :ok = :chumak.set_socket_option(push, :curve_secretkey, client_secret)
    :ok = :chumak.set_socket_option(push, :curve_publickey, client_public)
    {:ok, _peer_id} = :chumak.connect(push, :tcp, pony_server, 7778)
    IO.puts("Push socket: #{inspect(push)}")

    IO.puts("connected")

    listen(10, pull, push)
  end

  defp listen(0, _pull, _push), do: IO.puts("exiting ...")

  defp listen(count, pull, push) do
    :chumak.send(push, "Elixir worker says: Ping countdown ##{count}")
    Process.sleep(1000)
    listen(count - 1, pull, push)

    # case :chumak.recv(pull) do
    #   {:ok, body} ->
    #     Logger.info(body)
    #     listen(count - 1, pull, push)

    #   err ->
    #     IO.puts("Shutting down Elixir worker: #{err}")
    # end
  end
end
