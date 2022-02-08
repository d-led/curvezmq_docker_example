defmodule ElixirWorker.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_worker,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: true,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ElixirWorker, 10},
      extra_applications: [:logger, :chumak]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:chumak, "~> 1.4"},
      # {:nacerl, git: "https://github.com/willemdj/NaCerl"},
      {:chumak, git: "https://github.com/d-led/chumak"},
      # {:enacl, "~> 1.2"}
      {:enacl, git: "https://github.com/jlouis/enacl"},
    ]
  end
end
