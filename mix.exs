defmodule ExBanking.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :ex_banking,
      version: "0.2.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {ExBanking.Application, []}
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:decimal, "~> 2.0"},
      {:uuid, "~> 1.1"},
      {:accessible, "~> 0.3.0"},
      {:faker, "~> 0.17", only: :test},
      {:cachex, "~> 3.4"},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp aliases do
    [
      "code.quality": ["credo", "dialyzer"]
    ]
  end
end
