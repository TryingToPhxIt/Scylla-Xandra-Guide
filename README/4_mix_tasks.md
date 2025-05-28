#  Mix Tasks

`lib/mix/scylla/*.ex`

**Commands:**

| Command                    | Description                                                        |
|----------------------------|--------------------------------------------------------------------|
| mix scylla.create          | Creates all tables. If a table already exists, it will be skipped. |
| mix scylla.drop all        | Drops all tables.                                                  |
| mix scylla.drop table_name | Drops a specific named table. Use with caution.                    |
| mix scylla.seeds           | Can be used to seed the database.                                  |
| mix scylla.reset           | Drops all tables, creates all tables, then runs seeds.             |
