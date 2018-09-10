
#exit
require "snenglish"
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'root',
  password: '',
  database: 'english_dev'
)
# --------
ActiveRecord::Base.logger = Logger.new(STDOUT)


require 'progressbar'
def load_csv(myclass, csv_file)  
  puts "Loading..."
  puts "#{myclass.name}, #{csv_file}"
  progressbar = ProgressBar.create(:title => myclass.name ,  :format => '%e %B %p%%')
  
  csv_database_size = File.size(csv_file)
  rows_size = 0
  percent = 0
  
  myclass.load_csv( csv_file, last_comparing: '180114' ) do |row|
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

load_csv(SNEnglish::WordRate, "D:/Personal files/Alex/English/rate.csv" )