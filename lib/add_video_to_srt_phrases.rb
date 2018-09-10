# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

#!/usr/bin/ruby
#
#------------------------- parse arguments 

require 'optparse'
phrase = nil
input1 = nil
video_file = nil
OptionParser.new do |opts|
  
  filename = File.basename($0)
  opts.banner = "Usage: #{filename} [options]"
  
  opts.on('-i', '--input1 SRT', 'a path to srt-file') do |srt|    
    input1 = srt
  end
  
  opts.on('-v','--video VIDEO ', 'a video file name') do |video|
    video_file = video
  end
  
  opts.on('-p', '--phrase ENGLISH_PHRASE', 'phrase to save') do |english_phrase|
    phrase = english_phrase
  end
  
  opts.on_tail('-h', '--help', 'Show this help') do    
    puts opts
    exit
  end    
end.parse!
#-----

#puts video_file
#puts input1
#puts phrase
should_exit = phrase.nil? || input1.nil? || video_file.nil?

#puts "exit" if should_exit
exit if should_exit

database_name = 'english'  
$LOAD_PATH.push 'D:/Personal files/Alex/English/ruby/MakePhrases/lib'

require "snenglish"

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'root',
  password: '',
  database: database_name
)

srt_phrase = SNEnglish::SrtPhrase.find_by(english_phrase: phrase, file_path: input1)

unless srt_phrase.nil?
  puts "saving #{video_file}"
  srt_phrase.sound = "[sound:#{video_file}]"
  srt_phrase.save  
end
