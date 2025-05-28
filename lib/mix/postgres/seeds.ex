defmodule Mix.Tasks.Ecto.Seeds do
  @moduledoc """
  This task is used to create all tables in the Scylla database.

  **This task only runs in the :dev environment. It should be removed in production**

  Important: ALL seeds will run whenever this command is executed.  
  It should only be used when first creating and migrating or it may trigger database constaints.

  Command

    mix ecto.seeds

  """
  use Mix.Task

  @shortdoc "Seeds Postgres tables (dev only)"

  def run(_args) do
    if Mix.env() != :dev do
      Mix.raise("This task can only be run in the :dev environment.")
    end

    System.cmd("mix", ["run", "priv/repo/migrations/postgres/seeds.exs"], into: IO.stream(:stdio, :line))
  end
end
