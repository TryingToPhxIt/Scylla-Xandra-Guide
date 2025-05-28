defmodule Helpers.PhxieScylla do
  @moduledoc """
  A module for Scylla helpers.
  """

  def to_page({:ok, page}),      do: page
  def to_page({:error, reason}), do: {:error, reason}

  def to_list({:ok, page}),      do: Enum.to_list(page)
  def to_list({:error, reason}), do: {:error, reason}
  
  def get_one({:ok, page}),      do: Enum.to_list(page) |> List.first()
  def get_one({:error, reason}), do: {:error, reason}

  def paging_opts(size, state) do
    [page_size: size] ++ if state, do: [paging_state: state], else: []
  end
end