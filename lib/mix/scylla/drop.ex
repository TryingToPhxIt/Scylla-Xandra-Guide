defmodule Mix.Tasks.Scylla.Drop do
  @moduledoc """
  This task is used to drop specific or all tables in the Scylla database.

  **This task only runs in the :dev environment. It should be removed in production**

  Arguments

  - `all`           :  Drops all tables listed in the migration.
  - `<table_name>`  :  Drops the specific table if it exists. 

  Commands

    mix scylla.drop all    :  Drops all tables in the database
    mix scylla.drop posts  :  Drops the 'posts' table if it exists

  """
  use Mix.Task

  @shortdoc "Drops specific or all Scylla tables"
  
  def run(args) do
    if Mix.env() != :dev do
      Mix.raise("This task can only be run in the :dev environment.")
    end

    System.cmd("mix", ["run", "priv/repo/migrations/scylla/drop.exs", hd(args)])
  end
end
