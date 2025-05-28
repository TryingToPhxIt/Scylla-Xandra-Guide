defmodule Scylla.PostQuery do

##################
####  Create  ####
##################

  def create_post() do
    """
      INSERT INTO posts (
        post_id, 
        title, body,
        created_at, updated_at
      ) 
      VALUES 
      (
        ?,      -- ID
        ?, ?,   -- Meta
        ?, ?    -- Datetime
      )
    """
  end

##################
####  Update  ####
##################

  def update_post() do
    """
      UPDATE posts
      SET title = ?, body = ?, updated_at = ?
      WHERE post_id = ?
    """
  end

##################
####  Delete  ####
##################

  def delete_post() do
    """
      DELETE FROM posts
      WHERE post_id = ?
    """
  end

###############
####  Get  ####
###############

  def get_post() do
    """
      SELECT * FROM posts
      WHERE post_id = ?
    """
  end

################
####  List  ####
################

  def list_posts_by_id() do
    """
      SELECT * FROM posts 
      WHERE post_id IN ?
    """
  end  
end