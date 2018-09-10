# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
require './application_record'
require 'srt'


class Movie < ApplicationRecord
  has_many :phrases
  def add_movie( srt_file_name )    
    
    if not File.exists?( srt_file_name ) 
      raise IOError, "#{srt_file_name}, no such file"
    end
    
    video_file_name = srt_file_name.sub(/.srt$/, '.mp4')    
    if not File.exists?( video_file_name ) 
      raise IOError, "File #{video_file_name} not found"
    end
    
    #videoFile = File::new( videoFileName )
    srt_file = File.new( srt_file_name )    
    srt = SRT::File.parse( srt_file )
    
    movie = Movie.find_by(
      :fileName => File.dirname( srt_file_name ) 
    )    
    if movie.nil?
      # there is no such movie, we about to add it
    else
      # let's update it
    end  
    
  end
end

class Phrase < ApplicationRecord
  belongs_to :movie
end
