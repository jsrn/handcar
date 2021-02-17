require "sqlite3"

conn = SQLite3::Database.new "db/development.db"
conn.execute <<~SQL
  create table my_table (
  id INTEGER PRIMARY KEY,
  name VARCHAR(30));
  )
SQL
