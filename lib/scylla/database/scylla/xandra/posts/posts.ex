defmodule Scylla.Posts do

  alias Helpers.PhxieScylla
  alias Scylla.{PostQuery, PostRefQuery}

##################
####  Create  ####
##################

  @create_post     PostQuery.create_post()
  @create_post_ref PostRefQuery.create_post_ref()

  def create_post(params, _socket) do
    date     = Timex.now()
    post_id  = Ecto.UUID.generate()

    batch =
    Xandra.Batch.new()
    |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, @create_post_ref), [post_id, date])
    |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, @create_post), [post_id, params["title"], params["body"], date, date])
 
    case Xandra.execute(:scylla_db, batch) do
      {:ok, _void} ->
           
        {:ok, post_id}

      {:error, reason} ->
          IO.inspect(reason)
        {:error, reason}
    end
  end

##################
####  Update  ####
##################

  @update_post PostQuery.update_post() 

  def update_post(post_id, params) do
    Xandra.execute(:scylla_db, Xandra.prepare!(:scylla_db, @update_post), [params["title"], params["body"], Timex.now(), post_id])
  end

##################
####  Delete  ####
##################

  @delete_post     PostQuery.delete_post() 
  @delete_post_ref PostRefQuery.delete_post_ref() 

  def delete_post(post_id) do
    post = get_post(post_id) 
    |> PhxieScylla.get_one()

    batch =
    Xandra.Batch.new()
    |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, @delete_post),     [post_id])
    |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, @delete_post_ref), [post_id, 1, post["updated_at"]])

    case Xandra.execute(:scylla_db, batch) do
      {:ok, _void}     -> {:ok, :deleted}
      {:error, reason} -> {:error, reason}
    end
  end

###############
####  Get  ####
###############

  @get_post PostQuery.get_post()

  def get_post(post_id) do
    Xandra.execute(:scylla_db, Xandra.prepare!(:scylla_db, @get_post), [post_id])
  end

################
####  List  ####
################

  @list_posts_by_id PostQuery.list_posts_by_id()

  def list_posts_by_id(post_ids) do
    Xandra.execute(:scylla_db, Xandra.prepare!(:scylla_db, @list_posts_by_id), [post_ids])
  end
end