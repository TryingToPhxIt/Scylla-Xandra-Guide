defmodule Scylla.Migrations.Seeds do

  defp start_connection do
    {:ok, conn} = Xandra.start_link(keyspace: "scyllaDB", nodes: ["127.0.0.1:9042"])
    conn
  end

  def seed_user_metrics(conn) do
    for user_id <- 1..10 do
      Xandra.execute!(conn, """
        INSERT INTO user_metrics (
          user_id, 
          account_view_count, post_view_count, 
          post_count, comment_count, repost_count, 
          block_count
        )
        VALUES (
          #{user_id}, 
          0, 0, 
          0, 0, 0, 
          0
        );
      """)
    end
  end

  def run do
    conn = start_connection()

    seed_user_metrics(conn)
  end
end

Scylla.Migrations.Seeds.run()