#! ruby -Ku
#encoding: utf-8

require 'rubygems'
require 'sqlite3'
require 'pry-byebug'

class JugeBooleanValues
  def check_boolean_values(db, record_num)
    boolean_value = 0
    all_record = db.execute("SELECT * FROM cleanup;")

    for count in 1..record_num do
      boolean_value = boolean_value + all_record[count - 1][3]
    end
    boolean_value
  end

  def reset_boolean_values(db)
    db.execute("update cleanup set boolean = 0;")
  end

  def select_record_randomly(db)
    db.execute("SELECT * FROM cleanup where boolean = 0;").sample(1)
  end

  def change_boolean_value(select, db)
    db.execute("update cleanup set boolean = 1 where id = #{select[0]};")
  end
end

class Action < JugeBooleanValues
  def initialize
    @cleanup = JugeBooleanValues.new()
    @db = SQLite3::Database.new("/vagrant/sqlite/cleanup.sqlite3")
    @record_num = @db.execute("select count(*) from cleanup;")[0][0]
    @locations = {1 => "居間", 2 => "玄関・台所"}
  end

  def execute_selected_action(action_name)
    method(action_name).call
  end

  def create_action
    print "\n【場所】\n#{@locations.to_a}の中から選んでください(入力は「番号」です)："; location = gets.chomp
    print "\n【ミッション】\n５分程度で終わる内容にしてください："; action = gets.chomp
    @db.execute("insert into cleanup values(#{@record_num + 1}, ?, ?, 0, 1)", location, action)
    @db.close
  end

  def auto_select_action
    if @cleanup.check_boolean_values(@db, @record_num) == @record_num
      @cleanup.reset_boolean_values(@db)
      puts "\n一通りの掃除は終了されています！！！おつかれさまです！！！\n今日は一日お休みです！！！！\n\n"
    else
      select = @cleanup.select_record_randomly(@db)
      @cleanup.change_boolean_value(select[0], @db)
      puts "\n#本日のお掃除ミッション#\nヾ(*・ω・)ノ【#{select[0][2]}】ヾ(・ω・*)ノ\n\n"
    end
    @db.close
  end
end

class Display < Action
  def initialize
    @action = Action.new()
  end

  def menu
    serial_num = 1
    items = ["掃除アクションの追加", "本日のお掃除ミッションの自動選択"]
    key = {1 => "create_action", 2 => "auto_select_action"}

    puts "実行したい項目の「番号」を選んでください。\n"
    items.each do |item|
      puts "No.#{serial_num} #{item}"
      serial_num += 1
    end
    print "選択番号："; item_num = gets.chomp
    @action.execute_selected_action(key[item_num.to_i])
  end
end

Display.new().menu

