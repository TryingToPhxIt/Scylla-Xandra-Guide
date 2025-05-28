defmodule ScyllaWeb.HomeLive.Index do
  use ScyllaWeb, :live_view

  alias Helpers.PhxieScylla
  alias Scylla.{Posts, Post_Process}

  @impl true
  def mount(_params, _session, socket) do    
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end
  
  defp apply_action(socket, :index, _params) do 
    {posts, paging_state} = Post_Process.list_posts()

    socket
    |> assign(:posts, posts)
    |> assign(:paging_state, paging_state)
  end

  defp apply_action(socket, :create, _params) do 
    socket
  end

  defp apply_action(socket, :edit, params) do 
    socket
    |> assign(:post, Posts.get_post(params["post_id"]) |> PhxieScylla.get_one())
  end
  
  @impl true
  def handle_event("delete post", %{"post_id" => post_id}, socket) do
    Posts.delete_post(post_id)

    {:noreply, push_navigate(socket, to: ~p"/")}
  end
  
  def handle_event("load more", _params, socket) do
    {posts, paging_state} = Post_Process.list_posts(socket.assigns.paging_state)

    {:noreply,     
      socket
      |> assign(:posts, socket.assigns.posts ++ posts)
      |> assign(:paging_state, paging_state)}
  end
end