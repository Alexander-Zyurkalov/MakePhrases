#!/usr/bin/ruby
#
#------------------------- parse arguments 

require 'optparse'
args = {  }
OptionParser.new do |opts|
  
  filename = File.basename($0)
  opts.banner = "Usage: #{filename} [options]"
 
  # TODO describe parameters 
  args[:csv_database] = 'D:\\Common files\\English\\database.csv'
  opts.on('-d', '--csv_database FILE', '') do |file|    
    args[:csv_database] = file
  end
 
  args[:csv_phrases] = '.\\phrases.csv'
  opts.on('-p', '--phrases FILE', '') do |file|    
    args[:csv_phrases] = file
  end
  
  args[:csv_words] = '.\\words.csv'
  opts.on('-w', '--csv_words FILE', '') do |file|    
    args[:csv_words] = file
  end
  

  
  args[:test] = false
  opts.on('-t', '--test', 'Use the test database') do 
    args[:test] = true
  end
  
  opts.on_tail('-h', '--help', 'Show this help') do    
    puts opts
    exit
  end    
end.parse!
#-------------------------

# TODO check parameters

# -------- prepare the database
if args[:test]
  database_name = 'english_dev'
else
  database_name = 'english'  
end

puts database_name

puts args[:csv_words]

#exit
require "snenglish"
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'dbuser',
  password: 'dbuser',
  database: database_name
)
# --------

#ActiveRecord::Base.logger = Logger.new(STDOUT)

#puts "OK"
#puts SNEnglish::EnglishWord.find_by(:id => 1262).word_count.count_id
#puts "OK"
#
#exit


require 'progressbar'
def load_csv(csv_file)  
  puts "Loading..."  
  progressbar = ProgressBar.create(:title => "words" ,  :format => '%e %B %p%%')
  
  csv_database_size = File.size(csv_file)
  rows_size = 0
  percent = 0
  
  SNEnglish::EnglishWord.load_csv_with_counting(csv_file, last_comparing: '180114' ) do |row|
    for i in (0..10) do 
      rows_size += row[i].to_s.bytes.count + 1    
    end

    if  percent < (rows_size.to_f/csv_database_size*100).to_i and percent < 100
      progressbar.increment
      
      percent += 1
    end  
  end
  progressbar.finish
end


load_csv(args[:csv_words]) unless args[:csv_words] == nil
