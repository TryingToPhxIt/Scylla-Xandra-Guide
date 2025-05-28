defmodule Mix.Tasks.Scylla.Reset do
  @moduledoc """
  This task resets the Scylla database by dropping all tables, recreating them, and seeding the data.

  **This task only runs in the :dev environment. It should be removed in production**

  Command:

    mix scylla.reset

  """
  use Mix.Task

  @shortdoc "Drops all tables, recreates them, and seeds the database"

  def run(_args) do
    if Mix.env() != :dev do
      Mix.raise("This task can only be run in the :dev environment.")
    end

    Mix.shell().cmd("mix scylla.drop all")
    Mix.shell().cmd("mix scylla.create")
    Mix.shell().cmd("mix scylla.seeds")
  end
end
