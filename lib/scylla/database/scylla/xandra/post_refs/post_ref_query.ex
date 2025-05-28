defmodule Scylla.PostRefQuery do

##################
####  Create  ####
##################

  def create_post_ref() do
    """
      INSERT INTO post_refs (post_id, user_id, created_at)
      VALUES (?, 1, ?)
    """
  end

##################
####  Delete  ####
##################
  
  def delete_post_ref() do
    """
      DELETE FROM post_refs
      WHERE post_id = ? AND user_id = ? AND created_at = ? 
    """
  end

################
####  List  ####
################

  def list_post_refs() do
    """
      SELECT post_id, created_at FROM post_refs
      WHERE user_id = ?
      ORDER BY created_at DESC 
    """
  end
end