defmodule Gald.Mixfile do
  use Mix.Project

  def project do
    [app: :gald,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger],
     mod: {Gald, []}]
  end

  defp deps do
    [
      {:dialyze, "~> 0.2.0"},
      {:short_maps, "~> 0.1.0"},
      {:credo, "~> 0.1.0"}
    ]
  end
end