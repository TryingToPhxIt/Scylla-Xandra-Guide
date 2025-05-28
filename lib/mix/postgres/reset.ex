defmodule Mix.Tasks.Ecto.Reset do
  @moduledoc """
  Fully resets the database by dropping, creating, migrating, and seeding it.

  **This task only runs in the :dev environment. It should be removed in production**

  Command
  
    mix ecto.reset

  """
  use Mix.Task

  @shortdoc "Drops, creates, migrates, and seeds the Postgres database"

  def run(_args) do
    if Mix.env() != :dev do
      Mix.raise("This task can only be run in the :dev environment.")
    end
    
    commands = [
      ["ecto.drop"],
      ["ecto.create"],
      ["ecto.migrate"],
      ["ecto.seeds"]
    ]

    Enum.each(commands, fn command ->
      System.cmd("mix", command, into: IO.stream(:stdio, :line))
    end)
  end
end
