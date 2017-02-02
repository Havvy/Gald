defmodule GaldSite.Mixfile do
  use Mix.Project

  def project, do: [
    app: :gald_site,
    version: "0.2.0",
    deps_path: "../../deps",
    lockfile: "../../mix.lock",
    elixir: "~> 1.1",
    elixirc_paths: elixirc_paths(Mix.env),
    compilers: [:phoenix] ++ Mix.compilers,
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps: deps()
  ]

  def application, do: [
    mod: {GaldSite, []},
    applications: [
      :phoenix,
      :phoenix_pubsub,
      :phoenix_html,
      :cowboy,
      :logger,
      #:phoenix_ecto,
      #:postgrex,
      :gald
    ]
  ]

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [
      {:phoenix, "~> 1.2.0"},
      #{:phoenix_ecto, "~> 1.1"},
      #{:postgrex, ">= 0.0.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.3"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:cowboy, "~> 1.0"},
      {:short_maps, "~> 0.1.0"},
      {:gald, in_umbrella: true}
    ]
  end
end
