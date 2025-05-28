Pagination in Scylla/Xandra works by using a binary token known as a 'paging_state' and is very easy to implement.

#  Page

When a Xandra query is executed it returns {:ok, page}.

  ```elixir
    {:ok, 
      #Xandra.Page<[
        rows: [
          %{
            "created_at" => ~U[2025-05-28 11:49:18.019Z],
            "post_id" => "604361af-5637-4d9a-8b7d-21fe6148434f"
          },
          %{
            "created_at" => ~U[2025-05-28 11:46:38.149Z],
            "post_id" => "bf7fdbf7-dfa8-49e9-ad12-17c0d2b4f2ce"
          },
          %{
            "created_at" => ~U[2025-05-28 11:46:34.121Z],
            "post_id" => "9b1effe3-49b4-42cb-9f59-23b6ff00bc36"
          },
          %{
            "created_at" => ~U[2025-05-28 11:46:32.403Z],
            "post_id" => "d1678c91-1a38-4475-b26d-53a606d1622e"
          },
          %{
            "created_at" => ~U[2025-05-28 11:46:30.479Z],
            "post_id" => "3c9ecafe-1c36-4ff8-ac09-ec52fe2cf069"
          }
        ],
        tracing_id: nil,
        more_pages?: true
      ]>
    }
  ```

##  Page Size

  In the example above, 'more_pages?' displays a value of true. This is because 'page_size' was set as a paging option.
  Page size works similar to Postgres` 'limit', except it will generate a paging_state if the page_size is smaller than the data size.
  
  ```elixir
  Xandra.execute(:scylla_db, Xandra.prepare!(:scylla_db, statement), [value], page_size: integer)
  ```
  
  If page_size is not set, all results are returned.
  If page_size is less than the total number of results, a paginging state token will be created that can be used to paginate results.
  If page_size is more than the total number of results, the paging state will return as nil.

## Page Options

The below can be used on any table to easily paginate results.

`lib/helpers/scylla.ex`

  ```elixir
  def paging_opts(size, state) do
    [page_size: size] ++ if state, do: [paging_state: state], else: []
  end
  ```

To implement, all that needs to be done is the following:

  ```elixir
  @post_limit 5
  @list_post_refs PostRefQuery.list_post_refs()

  def list_post_refs(paging_state \\ nil) do
    Xandra.execute(:scylla_db, Xandra.prepare!(:scylla_db, @list_post_refs), [values], PhxieScylla.paging_opts(@post_limit, paging_state))
  end
  ```

##  Pagination Example

Firstly, return a list of posts and the post_ref paging_state as a tuple.

  ```elixir
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
  ```

Then assign the posts and paging_state to the socket.

  ```elixir
    defp apply_action(socket, :index, _params) do 
      {posts, paging_state} = Post_Process.list_posts()
  
      socket
      |> assign(:posts, posts)
      |> assign(:paging_state, paging_state)
    end
  ```

Pagination can then be triggered via infinite scroll or a button. Its important to remove the button/disable the scroll events when the paging_state
hits nil, as executing queries with nil/invalid paging_states will cause errors.

Click the button to trigger the event.

  ```elixir
  <.button :if={@paging_state} phx-click="load more">
    Load More
  </.button>
  ```

Pass the current paging_state in the socket to the function, then assign the new paging_state in its place.

  ```elixir
    def handle_event("load more", _params, socket) do
      {posts, paging_state} = Post_Process.list_posts(socket.assigns.paging_state)
  
      {:noreply,     
        socket
        |> assign(:posts, socket.assigns.posts ++ posts)
        |> assign(:paging_state, paging_state)}
    end
  ```
