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

class Action
  def initialize
    @display = Display.new()
    @cleanup = JugeBooleanValues.new()
    @locations = {1 => "居間", 2 => "玄関・台所"}
    @db = SQLite3::Database.new("/vagrant/sqlite/cleanup.sqlite3")
    @record_num = @db.execute("select count(*) from cleanup;")[0][0]
  end

  def execute_selected_action(action_name)
    method(action_name).call
  end

  def juge_continue_action(current_method_name = nil)
    if current_method_name.nil?
      print "\n本当にクローズしてもよろしいですか？(yes/no) => "; choice = gets.chomp
    else
      print "\n継続してこの処理を行いますか？(yes/no) => "; choice = gets.chomp
    end
    
    if /\Ayes\z/ =~ choice
      @db.close if current_method_name.nil?
      exit 0 if current_method_name.nil?
      execute_selected_action(current_method_name) unless current_method_name.nil?
    elsif /\Ano\z/ =~ choice
      @display.menu
    else
      puts "表記が誤っています。もう一度入力してください。"
      juge_continue_action(current_method_name)
    end
  end

  def create_action
    puts "\nお掃除エリアを選んださい。"
    @locations.each do |location|
      puts "#{location[0]}.【#{location[1]}】"
    end
    print "上記の中から選んでください(入力は「番号」です) => "; location = gets.chomp

    puts "ミッション内容を入力してください。５分程度で終わる内容がベストです。"
    print "ミッションの内容 => "; action = gets.chomp

    @db.execute("insert into cleanup values(#{@record_num + 1}, ?, ?, 0, 1)", location, action)
    juge_continue_action(__method__.to_s)
  end

  def auto_select_action
    if @cleanup.check_boolean_values(@db, @record_num) == @record_num
      @cleanup.reset_boolean_values(@db)
      puts "\n一通りの掃除は終了されています！！！おつかれさまです！！！\n今日は一日お休みです！！！！\n"
    else
      select = @cleanup.select_record_randomly(@db)
      @cleanup.change_boolean_value(select[0], @db)
      puts "\n#本日のお掃除ミッション#\nヾ(*・ω・)ノ【#{select[0][2]}】ヾ(・ω・*)ノ\n"
    end
    @display.menu
  end

  def list_action
    puts "\n【ミッション一覧】"
    @db.execute("select id, action, location from cleanup;").each do |record|
      puts "No.#{record[0]} #{record[1]}(場所:#{@locations[record[2]]})"
    end
    @display.menu
  end
end

class Display
  def menu
    @action = Action.new()

    items = ["お掃除ミッション一覧", "お掃除ミッション追加", "本日のお掃除ミッションを自動選択", "クローズする"]
    key = {2 => "create_action", 3 => "auto_select_action", 1 => "list_action", 4 => "juge_continue_action"}

    puts "\n実行したい項目の「番号」を選んでください。\n"
    items.each_with_index do |item, serial_num|
      puts "#{serial_num + 1}. #{item}"
    end
    print "選択番号 => "; item_num = gets.chomp
    @action.execute_selected_action(key[item_num.to_i])
  end
end

Display.new().menu

