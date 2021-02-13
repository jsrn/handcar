$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'simplecov'
SimpleCov.start

require "handcar"
require "rack/test"

require "minitest/autorun"
require 'sqlite3'

def reset_test_database(database)
  database.execute <<SQL
create table quotes (
id INTEGER PRIMARY KEY,
author VARCHAR(30),
submitter VARCHAR(30),
body VARCHAR(32000));
SQL
end
