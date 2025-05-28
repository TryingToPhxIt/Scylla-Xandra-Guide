defmodule Scylla.Table.Post do

  def table_name(), do: "posts"

  def schema() do
    [
      post_id:    "UUID",
      title:      "TEXT",
      body:       "TEXT",
      created_at: "TIMESTAMP",
      updated_at: "TIMESTAMP"
    ]
  end

  def primary_key() do
    "(post_id)"
  end

  def cluster_key() do
    nil
  end
end
