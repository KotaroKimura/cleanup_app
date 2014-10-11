#! ruby -Ku
#encoding: utf-8

require 'rubygems'
require 'sqlite3'
require 'pry-byebug'

class CleanUp
  def check_boolean_value(db, record_num)
    boolean_value = 0
    all_record = db.execute("SELECT * FROM cleanup;")

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

class Action
  def create_action(db, record_num)
    db.execute("insert into cleanup values(#{record_num + 1}, ?, ?, 0, 1)")
  end
end

cleanup = CleanUp.new()
db = SQLite3::Database.new("/vagrant/sqlite/cleanup.sqlite3")
record_num = db.execute("select count(*) from cleanup;")[0][0]

if cleanup.check_boolean_value(db, record_num) == record_num
  cleanup.restart_cleanup_action(db)
  puts "一通りの掃除は終了されています！！！おつかれさまです！！！\n今日は一日お休みです！！！！\n\n"
else
  select = cleanup.select_cleanup_action(db)
  cleanup.done_cleanup_action(select[0], db)
  puts "#本日のお掃除ミッション#\nヾ(*・ω・)ノ【#{select[0][2]}】ヾ(・ω・*)ノ\n\n"
end

db.close

