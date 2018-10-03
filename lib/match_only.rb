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
  
  args[:csv_words] = '.\\words.csv'
  opts.on('-w', '--csv_words FILE', '') do |file|    
    args[:csv_words] = file
  end
  
  opts.on('-2', '--csv_words2 FILE', '') do |file|    
    args[:csv_words2] = file
  end
  
  
  args[:csv_phrases] = '.\\phrases.csv'
  opts.on('-p', '--phrases FILE', '') do |file|    
    args[:csv_phrases] = file
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
puts args[:csv_database]
puts args[:csv_words]
puts args[:csv_phrases]
#exit
require "snenglish"
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'dbuser',
  password: 'dbuser',
  database: database_name
)
## --------
#puts "OK"
#puts SNEnglish::EnglishWord.find_by(:id => 3510).word_count.count_id
#puts "OK"
#
#exit


require 'progressbar'
#ActiveRecord::Base.logger = Logger.new(STDOUT)

def do_matching_for_all(myclass)
  puts "Matching..."
  title =  'Matching new words with phrases' if myclass.is_a? SNEnglish::WordMatchingTask
  title =  'Matching new phrases with words' if myclass.is_a? SNEnglish::SrtPhraseMatchingTask
  puts title
  progressbar = ProgressBar.create(
    title: title,
    format: '%e %B %p%%',
    total: myclass.count('*')
  )
  myclass.do_matching_for_all do |task|    
    progressbar.log task.english_word.english if myclass.is_a? SNEnglish::WordMatchingTask
    progressbar.log task.srt_phrase.english_phrase if myclass.is_a? SNEnglish::SrtPhraseMatchingTask
    progressbar.increment  
  end
end
do_matching_for_all(SNEnglish::WordMatchingTask)
do_matching_for_all(SNEnglish::SrtPhraseMatchingTask)


def save_csv(myclass, csv_file)
  puts "Saving..."
  progressbar = ProgressBar.create(
    :title => "Saving #{csv_file}" ,  
    :format => '%e %B %p%%',
    :total => myclass.count(:id)
  )  
  myclass.save_csv(csv_file) do
    progressbar.increment
  end
  progressbar.finish
end

save_csv(SNEnglish::WordPhraseRelation, args[:csv_phrases])
save_csv(SNEnglish::SrtPhrase, args[:csv_database])

  


# add better tests for updates word_phrase_relations
# add a test for adding words which already exist
# TODO make saving CSV-files
# TODO start saving in parse_lingual_leo
# TODO fix showed to shown
# TODO the same matching for phrases
# write unit tests for the procedures 