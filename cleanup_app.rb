#! ruby -Ku
#encoding: utf-8

require 'rubygems'
require 'sqlite3'
require 'pry-byebug'

DBPATH = "/vagrant/clean_up_app/cleanup.sqlite3"

db = SQLite3::Database.new(DBPATH)
all_record = db.execute("SELECT * FROM cleanup;")
record_num = db.execute("select count(*) from cleanup;")[0][0]
boolean_value = 0

for count in 1..record_num do
  all_record[count - 1][3]
  boolean_value = boolean_value + all_record[count - 1][3]
end

if boolean_value == record_num
  puts "booleanの値がすべてtrue" 
else
  puts "booleanの値が一つでもfalse"
end


#def main
  #db.execute("SELECT * FROM cleanup;") do |record|
  #	binding.pry
  #	if record[3] == 0
  #	  db.execute("update cleanup set boolean = 1 where id = #{record[0]}")
  #	  return record[2]
  #  else
  #	  main
  #  end
  #end
  #db.close
#end

#puts "本日の掃除は、　ヾ(*・ω・)ノ【" + main + "】ヾ(・ω・*)ノ　です！"