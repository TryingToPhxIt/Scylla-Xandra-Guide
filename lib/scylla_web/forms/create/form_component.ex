defmodule ScyllaWeb.NewPost.FormComponent do
  use ScyllaWeb, :live_component

  import Helpers.PhxieSchemaless
  alias Scylla.Posts

  @types %{title: :string, body: :string}
  @name "create-post"

  @impl true
  def update(assigns, socket) do 
    schemaless_update(%{}, @name, @types, assigns, socket)
  end
 
  @impl true
  def handle_event("validate", %{@name => params}, socket) do
    schemaless_validate(@types, @name, params, socket)
  end

  @impl true
  def handle_event("save", %{@name => params}, socket) do
    save(socket, socket.assigns.action, params)
  end

  defp save(socket, :create, params) do
    case Posts.create_post(params, socket) do
      {:ok, _post_id} -> 

        {:noreply, push_navigate(socket, to: ~p"/")}
    
      {:error, _reason} ->
        schemaless_reset_changeset(socket, @types, @name)
    end
  end 
end

