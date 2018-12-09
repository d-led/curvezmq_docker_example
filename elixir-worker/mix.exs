defmodule ElixirWorker.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_worker,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: true,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ElixirWorker, 10},
      extra_applications: [:logger, :chumak],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:chumak, "~> 1.2"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
