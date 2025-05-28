defmodule Scylla.PostRefs do

  alias Helpers.PhxieScylla
  alias Scylla.PostRefQuery

  @post_limit 5
  @list_post_refs  PostRefQuery.list_post_refs()

  def list_post_refs(paging_state \\ nil) do
    Xandra.execute(:scylla_db, Xandra.prepare!(:scylla_db, @list_post_refs), [1], PhxieScylla.paging_opts(@post_limit, paging_state))
  end
end