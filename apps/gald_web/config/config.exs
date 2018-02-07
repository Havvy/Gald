# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :gald_web,
       namespace: GaldWeb
       # ecto_repos: [Gald.Repo]

# Configures the endpoint
config :gald_web, GaldWeb.Endpoint,
  url: [host: "localhost"],
  # Note(Havvy): Removed when updating Phoenix to 1.3
  # root: Path.dirname(__DIR__),
  secret_key_base: "lvrGGgOE1ErFxNOLWlYUqhLxA7are54DqDaJmHDt7jbhmP3UiCslma0mTCvEGZWM",
  render_errors: [view: GaldWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GaldWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]
  # Note(Havvy): Removed when updating Phoneix to 1.3
  #server: true

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
