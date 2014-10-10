#! ruby -Ku
#encoding: utf-8

require 'rubygems'
require 'sqlite3'
require 'pry-byebug'

class BooleanValue
  def check_boolean_value(boolean_value, record_num, all_record)
    for count in 1..record_num do
      boolean_value = boolean_value + all_record[count - 1][3]
    end
    boolean_value
  end
end

class SelectCleanupAction
  def return_inital_values(db)
    db.execute("update cleanup set boolean = 0;")
  end

  def random_select(db)
    db.execute("SELECT * FROM cleanup ORDER BY RANDOM() limit 1;") do |one_record|
      db.execute("update cleanup set boolean = 1 where id = #{one_record[0]};")
    end
  end
end


DBPATH = "/vagrant/clean_up_app/cleanup.sqlite3"

db = SQLite3::Database.new(DBPATH)
all_record = db.execute("SELECT * FROM cleanup;")
record_num = db.execute("select count(*) from cleanup;")[0][0]
boolean_value = 0

if BooleanValue.new().check_boolean_value(boolean_value, record_num, all_record) == record_num
  SelectCleanupAction.new().return_inital_values(db)
  SelectCleanupAction.new().random_select(db)
else
  puts "booleanの値が一つでもfalse"
  #booleanが「0」のレコードを取得し、ランダムで選択
end

db.close


