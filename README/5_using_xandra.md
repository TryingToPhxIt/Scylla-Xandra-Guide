For full info on Xandra:

https://hexdocs.pm/xandra/Xandra.html

The below is not an explanation of how to use all of Xandra's features, but how to manage the file structure required to build, execute and process queries.
This is not an "official" file structure for handling Xandra queries, but it is a consistent way to seperate concerns if you are new to Scylla/Xandra.

Basic examples can be found in:

`lib/scylla/database/scylla/xandra/*`

All modules are split into two+ main file types depending on table data complexity and use. 
Simple join tables may only require a CQL query folder, whereas tables containing complex data may require:

1. CQL Query
2. Xandra Query Executions
3. Xandra Query Processing
4. Processing

##  CQL Query

Create a module dedicated to storing query data.

```elixir

  defmodule Scylla.PostQuery do

    def create_post_user() do
      """
        INSERT INTO post_ref_user (user_id, post_id, created_at)
        VALUES (12, ?, ?)
      """
    end

    def list_posts_by_id() do
      """
        SELECT * FROM posts 
        WHERE post_id IN ?
      """
    end  

    def delete_post() do
      """
        DELETE FROM posts
        WHERE post_id = ?
      """
    end
  end
```

### Types

Executions will fail if types do not match. 
You cannot pass an Integer value as the post_id in the below, it must be a UUID.

  ```elixir
    def schema() do
      [
        post_id:    "UUID",
        created_at: "TIMESTAMP"
      ]
    end
  ```

###  Order

Order matters. For setting defaults, values can be hardcoded like the status values below.
Rather than type all values in a row, split them into groups and mark them with `-- flags`.

Omitting a value will set it to null in Scylla, `status_reason` could be omitted from the query entirely, and would default to null.

  ```elixir
    def create_post() do
      """
        INSERT INTO posts (
          post_id, user_id, board_id, parent_id,
          type,
          user_tag, board_tag,
          quote, deleted, status_reason,
          privacy, 
          title, body, 
          media_layout,
          contains_poll,
          send_notification, upvote_notification, comment_notification, 
          created_at, updated_at
        ) 
        VALUES 
        (
          ?, ?, ?, ?,      -- Ids
          ?,               -- Type
          ?, ?,            -- Tags
          ?, false, null,  -- Status
          ?,               -- Privacy
          ?, ?,            -- Text Content
          ?,               -- Media Layout
          ?,               -- Contains Poll
          ?, ?, ?,         -- Notifications
          ?, ?             -- Datetime
        )
      """
    end
  ```

## Xandra Query Execution

This module is purely dedicated to executing queries. It should pull queires from CQL Query and if required pull query variables from a Query Processing module.

  Note: Do not add Xandra.prepare!(:scylla_db, *) into memory, it will not work as @types are loaded at the same time :scylla_db is being set up.

  ```elixir
  defmodule Scylla.Posts do

    @get_post PostQuery.get_post()
  
    def get_post(post_id) do
      Xandra.execute(:scylla_db, Xandra.prepare!(:scylla_db, @get_post), [post_id])
    end

    @delete_post         PostQuery.delete_post() 
    @delete_post_user    PostQuery.delete_post_user() 
    @delete_post_board   PostQuery.delete_post_board() 
    @delete_post_metrics PostMetricsQuery.delete_post_metrics() 

    def delete_post(post_id) do
      {:ok, post} = get_post(post_id)

      batch =
      Xandra.Batch.new()
      |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, @delete_post),         [post_id])
      |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, @delete_post_metrics), [post_id])
      |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, @delete_post_user),    [post["user_id"], post_id, post["created_at"]])

      batch = handle_board(batch, @delete_post_board, post["board_id"], post_id, post["created_at"]) 

      case Xandra.execute(:scylla_db, batch) do
        {:ok, _void}     -> {:ok, :deleted}
        {:error, reason} -> {:error, reason}
      end
    end
  end
```

##  Xandra Query Processing
  
```elixir
  defmodule Scylla.Post do

    def new_post_values(user, post_id, date, socket, params) do
      assigns    = socket.assigns
      board      = assigns.board
      parent_id  = assigns.quote_post["post_id"]
      quote_post = if parent_id, do: true, else: false 

        [
          post_id, user.id, (board.id || nil), parent_id,
          post_type(assigns.post_type),
          assigns.user_tag.id, assigns.board_tag.id,
          quote_post,
          params["privacy"],  
          params["title"], params["body"],
          assigns.media_layout,
          assigns.poll.contains_poll
        ] 
        ++ notification_settings(params) 
        ++ [date, date]
      end
    end
  end
```

The above is used in the batch below as the variable list for the final batch.

For complex data structures, create a query processing module to handle the variable list.

```elixir
    batch =
    Xandra.Batch.new()
    |> handle_hashtags(hashtags, post_id, date)
    |> handle_tags(socket.assigns, post_id, date)
    |> handle_board(board_query, socket.assigns.board.id, post_id, date)
    |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, user_query), [current_user.id, post_id, date])
    |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, @create_post_metrics), [post_id, date, date])
    |> Xandra.Batch.add(Xandra.prepare!(:scylla_db, @create_post), Post.new_post_values(current_user, post_id, date, socket, params))
 ```

## Processing

For complex data that requires processing from multiple sources, create a dedicated processing module that pulls from the Xandra Query Execution module.

The below pulls data from multiple Scylla tables, Elasticsearch and Redis to "build" a post.

```elixir
  defmodule Scylla.PostProcess do

    def process_posts(user_id, post_ids, client_id) do
      {:ok, posts} = Posts.list_posts_by_id(post_ids)
  
      parent_ids   = posts |> Enum.map(& &1["parent_id"]) |> Enum.reject(&is_nil/1)
      all_post_ids = post_ids ++ parent_ids |> Enum.uniq()
    
      {:ok, all_posts} = Posts.list_posts_by_id(all_post_ids)
      {:ok, image}     = Images.list_post_images(all_post_ids)
      {:ok, video}     = Videos.list_post_videos(all_post_ids)
    
      users      = ElasticQuery.get_content_user_info(all_posts, "users",  "user_id")
      boards     = ElasticQuery.get_content_user_info(all_posts, "boards", "board_id")

      user_tags  = get_tags(all_posts, "user_tag",  "User")
      board_tags = get_tags(all_posts, "board_tag", "Board")
      image_map  = group_by_post_id(image)
      video_map  = group_by_post_id(video)
      metrics    = get_post_metrics(all_post_ids)
      votes      = get_post_votes(all_post_ids, user_id)

      {viewed_posts, viewed_images} = PostView.get_post_views(user_id, post_ids, client_id)

      processed_images =
        Enum.into(image_map, %{}, fn {post_id, images} ->
          updated_images =
            Enum.map(images, fn image ->
              viewed = Enum.any?(viewed_images, fn viewed_id -> viewed_id == image["id"] end)
              Map.put(image, "viewed", viewed)
            end)

          {post_id, updated_images}
        end)

      posts_by_id =
        Enum.into(all_posts, %{}, fn post ->
          post_id = post["post_id"]
          {poll, options} = maybe_create_poll(post_id, post["contains_poll"])
    
          metric    = Enum.find(metrics, &(&1["post_id"] == post_id)) || %{}
          user_vote = Enum.find(votes,   &(&1["post_id"] == post_id))
          user_view = Enum.member?(viewed_posts, post_id)

          {
            post_id,
            post
            |> Map.put("poll",         poll)
            |> Map.put("poll_options", options)
            |> Map.put("user_view",    user_view || "false")
            |> Map.put("user_vote",    user_vote["value"] || 0)
            |> Map.put("images",       Map.get(processed_images,  post_id, []))
            |> Map.put("video",        Map.get(video_map,  post_id, []))
            |> Map.put("user",         Map.get(users,      post["user_id"]))
            |> Map.put("board",        Map.get(boards,     post["board_id"]))
            |> Map.put("user_tag",     Map.get(user_tags,  post["user_tag"]))
            |> Map.put("board_tag",    Map.get(board_tags, post["board_tag"]))
            |> Map.merge(metric)
          }
        end)

      Enum.map(post_ids, fn post_id ->
        post = Map.get(posts_by_id, post_id)

        parent_post = Map.get(posts_by_id, post["parent_id"])
        Map.put(post, "parent_post", parent_post)
      end)
    end
  end
```
