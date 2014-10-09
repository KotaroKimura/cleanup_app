#! ruby -Ku
#encoding: utf-8

###データベースのカラムについて###
#・id: そのまま
#・locations: 場所(居間、台所)
#・action: 掃除を行うアクション(○○する)
#・boolean: やったorやってない
#・priority: 順序付け(使うかは未定)



require 'rubygems'
require 'sqlite3'
require 'pry-byebug'

DBNAME = "/vagrant/clean_up_app/cleanup.sqlite3"

def main
  db = SQLite3::Database.new(DBNAME)
  db.execute( "SELECT * FROM cleanup ORDER BY RANDOM() limit 1;") do |record|
  	binding.pry
  	if record[3] == 0
  	  db.execute("update cleanup set boolean = 1 where id = #{record[0]}")
  	  return record[2]
    else
  	  main
    end
  end
  db.close
end

puts "本日の掃除は、　ヾ(*・ω・)ノ【" + main + "】ヾ(・ω・*)ノ　です！"