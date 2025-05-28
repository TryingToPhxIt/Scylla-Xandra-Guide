defmodule Scylla.Post_Process do
  alias Helpers.PhxieScylla
  alias Scylla.{Posts, PostRefs}

  def list_posts(paging_state \\ nil) do
    {:ok, page} = PostRefs.list_post_refs(paging_state)

    posts = page
    |> Enum.to_list()
    |> Enum.map(& &1["post_id"])
    |> Posts.list_posts_by_id() 
    |> PhxieScylla.to_list()
    |> Enum.sort_by(& &1["created_at"], {:desc, DateTime})
    
    {posts, page.paging_state}
  end
end