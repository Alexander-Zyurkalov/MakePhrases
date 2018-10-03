# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
require "srt"
module Srt
  class SrtFixing
    def initialize
      SRT::File.parse_file('D:/Personal files/Alex/English/ruby/MakePhrases/test/srt/simple.srt').each_line do |line|
        puts line.text.join " "
      end
    end
  end
end

