defmodule Gald.Mixfile do
  use Mix.Project

  def project, do: [
    app: :gald,
    version: "0.2.0",
    deps_path: "../../deps",
    lockfile: "../../mix.lock",
    elixir: "~> 1.1",
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps: deps,
    name: "Gald",
    source_url: "https://github.com/havvy/gald",
    docs: [
      extra_section: "Concepts",
      extras: [
        "../../README.md",
        "../../doc/Combat.md",
        "../../doc/Screens.md",
        "../../doc/Snapshots.md",
      ]
    ]
  ]

  def application, do: [
    applications: [:logger, :destructure],
    mod: {Gald, []}
  ]

  defp deps, do: [
    {:destructure, "~> 0.1.1"},
    {:short_maps, "~> 0.1.0"},
    {:dialyze, "~> 0.2.0", only: :dev},
    #{:credo, "~> 0.1.0", only: :dev},
    {:ex_doc, "~> 0.11.2", only: :dev},
    {:earmark, ">= 0.0.0", only: :dev}
  ]
end