# Installation and Set Up Links

- **Download   :** https://www.scylladb.com/download/#tools  
- **CQL        :** http://docs.scylladb.com/stable/get-started/query-data/cql.html  
- **Keyspaces  :** https://docs.scylladb.com/stable/get-started/query-data/schema.html  

## CQL

To run CQL commands, open a terminal and run:  
`cqlsh`

## Keyspace

The keyspace is a namespace where tables are stored.

**Keyspace commands:**  
*(Replace `keyspace_name` with your keyspace name)*

- **CREATE**
  ```cql
  CREATE KEYSPACE IF NOT EXISTS keyspace_name 
  WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 3} 
  AND TABLETS = {'enabled': false};

- **DELETE**
Dropping a keyspace will delete all tables within it.

  ```cql
  DROP KEYSPACE keyspace_name;

- **VIEW**
Describing keyspaces will show all keyspace names, whereas describing the keyspace_name will show the entire config of the keyspace including all table configs.

  ```cql
  DESCRIBE KEYSPACES;
  DESCRIBE KEYSPACE keyspace_name;
