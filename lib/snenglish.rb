require 'application_record'
require 'csv' 

module SNEnglish 
  
  class Base < ApplicationRecord
    self.abstract_class = true 
    
    @@CSV_OPTS = { 
          quote_char: '"',
          col_sep: ',',  
          row_sep: :auto,
          headers: true, 
          encoding: "utf-8"
    }
    
    def update_tasks
            
    end    
    def set_attrs(rowHash)
      true
    end
    def add_columns_to_csv(row)
    end

    def self.was_updated?(rowHash,the_row_was_created)    
      (rowHash['created_at'] == nil || rowHash['created_at'] == '') &&
        !the_row_was_created
    end

    def self.load_csv(csv_database, last_comparing: '170101')
      begin
        self.transaction do   
          require 'fileutils'
          FileUtils.cp csv_database, (csv_database+'.bak')
          File.open(csv_database,"wb:UTF-8") do |file|           
            file.write "\xEF\xBB\xBF"        
            csv = CSV.generate_line(@HEADER,@@CSV_OPTS )
            file.write csv

            CSV.foreach(  (csv_database+'.bak'),  
                  quote_char: '"',  col_sep: ',',row_sep: :auto, headers: true, 
                  encoding: "bom|utf-8" ) do |row|
              
              rowHash = row.to_hash 
              next if row[0].nil? && row[1].nil? && row[2].nil?
              
              the_row_was_created = 
                rowHash['id'] == nil || 
                rowHash['id'] == ''
              the_row_was_updated = self.was_updated?(rowHash,the_row_was_created)
              the_row_was_created = false if the_row_was_updated
              obj = nil
              if the_row_was_created || the_row_was_updated
                obj = self.find_by( id: rowHash['id'] ) if the_row_was_updated ||
                    !rowHash['id'].nil? || rowHash['id'] != ''
                #if the_row_was_updated              
                obj = self.new() if obj == nil
                
                if obj.set_attrs(rowHash)                  
                  obj.save 
                  obj.update_tasks if rowHash['date'] != nil && 
                                      rowHash['date'] >= last_comparing
                end
                obj.add_columns_to_csv(row)
              end              
              yield(row,obj) if block_given?
              file.write CSV.generate_line(row,@@CSV_OPTS )

            end
          end       
                 
        end
      end
    rescue => err             
      ActiveRecord::Rollback                 
      FileUtils.cp (csv_database+'.bak'), csv_database
      raise err
    end
    
   
    
  end
end
require 'snenglish/user'
require 'snenglish/users_english_words'
require 'snenglish/srt_phrase'
require 'snenglish/english_word'
require 'snenglish/word_phrase_relation'
require 'snenglish/matching_task'
require 'snenglish/srt_phrase_matching_task'
require 'snenglish/word_matching_task'
require 'snenglish/shown_phrase'
require 'snenglish/word_count'
#require 'snenglish/word_rates'
