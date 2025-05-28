defmodule Helpers.PhxieSchemaless do
  @moduledoc """
  A module for handling Scylla and other schemaless forms.
  """

  use ScyllaWeb, :live_component
  import Ecto.Changeset

##################
####  Update  ####
##################

  @doc """
  Updates the form with the given parameters and assigns, returning a new socket with the changeset.

  @spec schemaless_update(map(), atom(), map(), map(), Phoenix.LiveView.Socket.t()) ::
    {:ok, Phoenix.LiveView.Socket.t()} | no_return()

  """

  def schemaless_update(params, name, types, assigns, socket) do
    changeset = schemaless_changeset(params, types)

    if Enum.any?(changeset.errors) do
      raise ArgumentError, "Changeset Error: #{inspect(changeset.errors)}"
    else
      {:ok,
        socket
        |> assign(assigns)
        |> assign(assigns |> Map.merge(params)) 
        |> assign(:form, to_form(changeset, as: name))
      }
    end
  end

#####################
####  Changeset  ####
#####################

  @doc """
  Generates a changeset from the provided parameters and types.

  @spec schemaless_changeset(map(), map()) :: Ecto.Changeset.t()

  """

  def schemaless_changeset(params, types) do
    {%{}, types}
    |> cast(params, Map.keys(types))
  end

  @doc """
  Generates a changeset with validation action from the given form, parameters, and types.

  @spec schemaless_validate_changeset(map(), map(), map()) :: Ecto.Changeset.t()

  """

  def schemaless_validate_changeset(params, form, types) do
    {form, types}
    |> cast(Map.merge(form.params, params), Map.keys(types))
    |> Map.put(:action, :validate)   
  end

  
  @doc """
  Resets the form on submission.

  @spec schemaless_reset_changeset(map(), map()) :: Ecto.Changeset.t()

  """

  def schemaless_reset_changeset(socket, types, name) do
    assign(socket, :form, to_form(schemaless_changeset(%{}, types), as: name))
  end

####################
####  Validate  ####
####################

  @doc """
  Validates the changeset based on the given parameters and updates the socket accordingly.

  @spec schemaless_validate(map(), atom(), map(), Phoenix.LiveView.Socket.t(), map()) ::
    {:noreply, Phoenix.LiveView.Socket.t()} | {:noreply, Phoenix.LiveView.Socket.t()}

  """
  def schemaless_validate(types, name, params, socket, optional_assigns \\ %{}) do
    form = socket.assigns.form
    params = Map.merge(form.params, params)

    changeset = 
      {form, types}
      |> cast(params, Map.keys(types))
      |> Map.put(:action, :validate)   

    if changeset.valid? do     
      socket = 
        socket
        |> assign(:changeset, changeset)
        |> assign(:form, to_form(changeset, as: name))

      socket = 
        Enum.reduce(optional_assigns, socket, fn {key, value}, acc ->
          assign(acc, key, value)
        end)

      {:noreply, socket}
    else
      {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
