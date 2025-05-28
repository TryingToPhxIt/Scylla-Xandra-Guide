defmodule Scylla.Migrations.Drop do
  
  defp start_connection do
    {:ok, conn} = Xandra.start_link(keyspace: "scyllaDB", nodes: ["127.0.0.1:9042"])
    conn
  end

  defp drop_table(conn, table) do
    Xandra.execute!(conn, "DROP TABLE IF EXISTS #{table};")
  end

  defp all_tables do
    Scylla.Tables.scylla_tables()
    |> Enum.map(&apply(&1, :table_name, []))
  end

  def run do
    conn = start_connection()

    case System.argv() do
      ["all"] -> Enum.each(all_tables(), &drop_table(conn, &1))
      [table] -> if table in all_tables(), do: drop_table(conn, table)
    end
  end
end

Scylla.Migrations.Drop.run()
