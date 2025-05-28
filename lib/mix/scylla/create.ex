defmodule Mix.Tasks.Scylla.Create do
  @moduledoc """
  This task is used to create all tables in the Scylla database.

  **This task only runs in the :dev environment. It should be removed in production**

  Command

    mix scylla.create

  """
  use Mix.Task

  @shortdoc "Creates all Scylla tables (dev only)"

  def run(_args) do
    if Mix.env() != :dev do
      Mix.raise("This task can only be run in the :dev environment.")
    end

    System.cmd("mix", ["run", "priv/repo/migrations/scylla/create.exs"], into: IO.stream(:stdio, :line))
  end
end


