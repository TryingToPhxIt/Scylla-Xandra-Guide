defmodule ScyllaWeb.EditPost.FormComponent do
  use ScyllaWeb, :live_component

  import Helpers.PhxieSchemaless
  alias Scylla.Posts

  @types %{title: :string, body: :string}
  @name "edit-post"

  @impl true
  def update(%{post: post} = assigns, socket) do
    schemaless_update(%{post: post}, @name, @types, assigns, socket)
  end
 
  @impl true
  def handle_event("validate", %{@name => params}, socket) do
    schemaless_validate(@types, @name, params, socket)
  end

  @impl true
  def handle_event("save", %{@name => params}, socket) do
    save(socket, socket.assigns.action, params)
  end

  defp save(socket, :edit, params) do
    case Posts.update_post(socket.assigns.post["post_id"], params) do
      {:ok, _post_id} -> 

        {:noreply, push_navigate(socket, to: ~p"/")}
    
      {:error, _reason} ->
        schemaless_reset_changeset(socket, @types, @name)
    end
  end
end