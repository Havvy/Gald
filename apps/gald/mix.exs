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
      {:short_maps, "~> 0.1.0"},
      {:dialyze, "~> 0.2.0", only: :dev},
      {:credo, "~> 0.1.0", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev}
    ]
  end
end