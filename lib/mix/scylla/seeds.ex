defmodule Mix.Tasks.Scylla.Seeds do
  @moduledoc """
  This task is used to seed the database if required.

  **This task only runs in the :dev environment. It should be removed in production**

  Command

    mix scylla.seeds

  """
  use Mix.Task

  @shortdoc "Seeds the Scylla database"

  def run(_args) do
    if Mix.env() != :dev do
      Mix.raise("This task can only be run in the :dev environment.")
    end
    
    System.cmd("mix", ["run", "priv/repo/migrations/scylla/seeds.exs"])
  end
end
