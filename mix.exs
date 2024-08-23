defmodule AssetPiper.MixProject do
  use Mix.Project

  def project do
    [
      app: :asset_piper,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AssetPiper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nx, "~> 0.7"},
      {:nx_image, "~> 0.1"},
      {:scholar, "~> 0.3"},
      {:exla, "~> 0.7"},
      {:kino, "~> 0.13"},
      {:image, "~> 0.51"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
