https://hex.pm/packages/xandra

### mix.exs

```elixir
defp deps do
  [
    {:xandra, "~> 0.19.2"}
  ]
end
```

Run:

```sh
mix deps.get
```

### config/dev.exs

```elixir
config :your_app, :xandra_repo,
  nodes: ["127.0.0.1:9042"],
  keyspace: "keyspace_name"
```

### config/test.exs

```elixir
config :your_app, :xandra_repo,
  nodes: ["127.0.0.1:9042"],
  keyspace: "keyspace_name"
```

### lib/scylla/application.ex

```elixir
def start(_type, _args) do
  xandra_config = Application.fetch_env!(:your_app, :xandra_repo)

  children = [
    {Xandra, Keyword.put(xandra_config, :name, :scylla_db)}
  ]

  opts = [strategy: :one_for_one, name: YourApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```

> Note: `:scylla_db` is a named value used when executing Xandra queries.
