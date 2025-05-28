#  Mix Tasks

`lib/mix/scylla/*.ex`

**Commands:**

- `mix scylla.create`  
- `mix scylla.drop all`  
- `mix scylla.drop table_name`  
- `mix scylla.seeds`  
- `mix scylla.reset`

| Command          | Description                                                        |
|------------------|--------------------------------------------------------------------|
| Create           | Creates all tables. If a table already exists, it will be skipped. |
| Drop All         | Drops all tables.                                                  |
| Drop table_name  | Drops a specific named table. Use with caution.                    |
| Seeds            | Can be used to seed the database.                                  |
| Reset            | Drops all tables, creates all tables, then runs seeds.             |
