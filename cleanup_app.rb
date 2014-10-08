#! ruby -Ku
#encoding: utf-8

require 'rubygems'
require 'sqlite3'

DBNAME = "/vagrant/clean_up_app/cleanup.sqlite3"
db = SQLite3::Database.new( DBNAME )

db.execute("SELECT * FROM personal") do |row|
	p row
end

db.close