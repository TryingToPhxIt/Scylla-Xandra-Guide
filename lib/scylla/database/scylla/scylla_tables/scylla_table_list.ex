defmodule Scylla.Tables do

  def scylla_tables() do
    [
      Scylla.Table.Post,
      Scylla.Table.PostRef
    ]
  end
end