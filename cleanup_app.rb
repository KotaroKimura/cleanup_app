#! ruby -Ku
#encoding: utf-8

require 'rubygems'
require 'sqlite3'
require 'pry-byebug'

class CleanUp
  def check_boolean_value(boolean_value, record_num, all_record)
    for count in 1..record_num do
      boolean_value = boolean_value + all_record[count - 1][3]
    end
    boolean_value
  end

  def restart_cleanup_action(db)
    db.execute("update cleanup set boolean = 0;")
  end

  def select_cleanup_action(db)
    db.execute("SELECT * FROM cleanup where boolean = 0;").sample(1)
  end

  def done_cleanup_action(select, db)
    db.execute("update cleanup set boolean = 1 where id = #{select[0]};")
  end
end


DBPATH = "/vagrant/clean_up_app/cleanup.sqlite3"

db = SQLite3::Database.new(DBPATH)
all_record = db.execute("SELECT * FROM cleanup;")
record_num = db.execute("select count(*) from cleanup;")[0][0]
boolean_value = 0

CleanUp.new().restart_cleanup_action(db) if CleanUp.new().check_boolean_value(boolean_value, record_num, all_record) == record_num
select = CleanUp.new().select_cleanup_action(db)
done = CleanUp.new().done_cleanup_action(select[0], db)

db.close


