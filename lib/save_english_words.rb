#!/usr/bin/ruby
#
#------------------------- parse arguments 

require 'optparse'
args = {  }
OptionParser.new do |opts|
  
  filename = File.basename($0)
  opts.banner = "Usage: #{filename} [options]"
  
  args[:csv_words] = '.\\words.csv'
  opts.on('-w', '--csv_words FILE', '') do |file|    
    args[:csv_words] = file
  end
  
  args[:user] = 1
  opts.on('-u', '--user', 'Use the test database') do |user|
    args[:user] = user
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
def save_csv(csv_file,user)  
  puts "Saving..."  
  progressbar = ProgressBar.create(:title => "words" ,  :format => '%e %B %p%%')
  number_of_words = SNEnglish::UsersEnglishWord.where(:user_id => user).count
  
  percent = 0
  i = 0
  SNEnglish::EnglishWord.save_csv(csv_file,user) do |row|    
#    puts "#{i},#{number_of_words},#{percent},#{i.to_f/number_of_words*100}"
    if  percent < (i.to_f/number_of_words*100).to_i and percent < 100
      progressbar.increment      
      percent += 1
    end  
    i = i + 1
  end
  progressbar.finish
end


save_csv(args[:csv_words],args[:user]) unless args[:csv_words] == nil
puts "Done."