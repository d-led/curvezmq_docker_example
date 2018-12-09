defmodule ElixirWorker do
  require Logger
  use Application

  @server_key Path.join(:code.priv_dir(:elixir_worker), "server.key")
  @client_key Path.join(:code.priv_dir(:elixir_worker), "client.key_secret")

  def start(_type, count) do
    IO.puts "Starting Elixir/Erlang worker"

    {:ok, [public_key: server_public]} = :chumak_cert.read(@server_key)
    {:ok, [public_key: client_public, secret_key: client_secret]} = :chumak_cert.read(@client_key)

    client_secret |> IO.inspect

    {:ok, pull} = :chumak.socket(:pull)
    :ok = :chumak.set_socket_option(pull, :curve_server, false)
    :ok = :chumak.set_socket_option(pull, :curve_serverkey, server_public)
    :ok = :chumak.set_socket_option(pull, :curve_secretkey, client_secret)
    :ok = :chumak.set_socket_option(pull, :curve_publickey, client_public)
    :chumak.connect(pull, :tcp, 'go-server', 7777)

    {:ok, push} = :chumak.socket(:push)
    :ok = :chumak.set_socket_option(push, :curve_server, false)
    :ok = :chumak.set_socket_option(push, :curve_serverkey, server_public)
    :ok = :chumak.set_socket_option(push, :curve_secretkey, client_secret)
    :ok = :chumak.set_socket_option(push, :curve_publickey, client_public)
    :chumak.connect(push, :tcp, 'go-server', 7778)

    listen(count, pull, push)

    IO.puts "Shutting down Elixir/Erlang worker"
    {:ok, self()}
  end

  defp listen(count, pull, push) do
    case :chumak.recv(pull) do
      {:ok, body} ->
        Logger.info body
        listen(count-1, pull, push)
      err ->
        IO.puts "Shutting down Elixir worker: #{err}"
    end
  end
end
