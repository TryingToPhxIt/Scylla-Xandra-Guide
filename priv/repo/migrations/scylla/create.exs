defmodule MigrationGenerator do
  def create_table(conn, module) do
    table_name = apply(module, :table_name, [])
    
    fields =
      for {field, type} <- apply(module, :schema, []) do
        "#{Atom.to_string(field)} #{type}"
      end

    primary_key = "PRIMARY KEY " <> apply(module, :primary_key, [])

    cluster_key = 
      case apply(module, :cluster_key, []) do
        nil -> ""
        key -> " WITH CLUSTERING ORDER BY #{key}"
      end

    query =
      "CREATE TABLE IF NOT EXISTS #{table_name} (" <>
        Enum.join(fields, ",") <> ", #{primary_key}) #{cluster_key};"

    Xandra.execute!(conn, query)
  end
end

defmodule RunMigrations do
  def run do
    {:ok, conn} = Xandra.start_link(keyspace: "scyllaDB", nodes: ["127.0.0.1:9042"])

    require MigrationGenerator

    Enum.each(Scylla.Tables.scylla_tables(), fn mod ->
      MigrationGenerator.create_table(conn, mod)
    end)
  end
end

RunMigrations.run()