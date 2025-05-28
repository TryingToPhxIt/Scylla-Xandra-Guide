# Migrations

`priv/repo/migrations/scylla/drop.exs`  
`priv/repo/migrations/scylla/create.exs`  
`lib/scylla/database/scylla/scylla/tables/scylla_table_list.ex`

`create.exs` and `drop.exs` scripts iterate through the `scylla_tables()` list in `tables/scylla_table_list.ex` to create or drop tables.

```elixir
  def scylla_tables() do
    [
      Scylla.Table.Post,
      Scylla.Table.Comment,
      Scylla.Table.Reply,
      Scylla.Table.Message
    ]
  end
```

# Table Data

All table modules must be in the format below for migrations to work correctly.

```elixir
  defmodule Scylla.Table.Comment do
  
    def table_name(), do: "comments"
  
    def schema() do
      [
        comment_id: "UUID",
        body:       "TEXT",
        ...
        created_at: "TIMESTAMP",
        updated_at: "TIMESTAMP"
      ]
    end
  
    def primary_key() do
      "((post_id), created_at, comment_id)"
    end
  
    def cluster_key() do
      "(created_at DESC)"
    end
  end
```

## Primary Key

  Must be a string starting and ending "()"

  "(post_id)"                             : Single key
  "((post_id), created_at, comment_id)"   : 'post_id' is the partition key; 'created_at' and 'comment_id' are clustering keys.
  "(user_1, user_2, room_id)"             : Composite primary key with no separate clustering.

##  Cluster Key
    
  Must be a string starting and ending "()"

  "(created_at DESC)"                   :  Single cluster order
  "(ancestor_id ASC, created_at DESC)"  :  Order first by ancestor, then by created_at
  nil                                   :  No Clustering required
