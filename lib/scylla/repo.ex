defmodule Scylla.Repo do
  use Ecto.Repo,
    otp_app: :scylla,
    adapter: Ecto.Adapters.Postgres
end
