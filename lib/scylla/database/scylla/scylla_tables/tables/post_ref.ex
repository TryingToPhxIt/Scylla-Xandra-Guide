defmodule Scylla.Table.PostRef do

  def table_name(), do: "post_refs"

  def schema() do
    [
      post_id:    "UUID",
      user_id:    "SMALLINT",
      created_at: "TIMESTAMP"
    ]
  end

  def primary_key() do
    "((user_id), created_at, post_id)"
  end

  def cluster_key() do
    "(created_at DESC)"
  end
end
