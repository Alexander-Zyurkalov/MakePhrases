module SNEnglish  
  
  class SrtPhraseAdditionalField < ApplicationRecord
    self.primary_key = 'srt_phrase_id'
    belongs_to :srt_phrase
  end
  class SrtPhrase < SNEnglish::Base 
    
    @@key = nil
    
    has_one :srt_phrase_matching_task
    has_many :word_phrase_relations
    has_many :english_words, through: :word_phrase_relations
    
    
    @HEADER = [
                "RussianPhrase","EnglishPhrase",
                "sound","prevPhrase","nextPhrase",
                "prevRussianPhrase", "nextRussianPhrase",
                "order","date","filePath","created_at",'id'
              ]  

    def set_attrs(rowHash)
      self.russian_phrase      = rowHash["RussianPhrase"]        
      self.english_phrase      = rowHash["EnglishPhrase"]
      self.sound               = rowHash["sound"]
      self.prev_phrase         = rowHash["prevPhrase"]
      self.next_phrase         = rowHash["nextPhrase"]
      self.prev_russian_phrase = rowHash["prevRussianPhrase"]
      self.next_russian_phrase = rowHash["nextRussianPhrase"]
      self.the_number_of_str   = rowHash["order"]
      self.added_at            = rowHash["date"]
      self.file_path           = rowHash["filePath"]
      #self.id                  = rowHash['id'] if rowHash['id']!= nil && 
      #                           rowHash['id'] != ''
      if self.id == nil
        @@key = self.class.maximum('id') if @@key.nil?
        @@key = 0 if @@key.nil?
        m = @@key + 1
        @@key = m
        self.id = m + 1 unless m.nil?
      end
      true
    end
    def add_columns_to_csv(row)
      if row.count < 11
        row.push self.created_at.to_i 
      else
        row[10] = self.created_at.to_i
      end
      if row.count < 12
        row.push self.id 
      else                  
        row[11] = self.id
      end      
    end
    def self.load_csv(csv_database, last_comparing: '170101')
      super csv_database, last_comparing: last_comparing
    end    

    def update_tasks
      if self.srt_phrase_matching_task == nil
        self.srt_phrase_matching_task = SrtPhraseMatchingTask.new(
            srt_phrase_id: self.id
        )      
        self.srt_phrase_matching_task.save
      end
    end
        
    def self.save_csv(csv_database)
      require 'fileutils'
      FileUtils.cp csv_database, (csv_database+'.bak')      
      File.open(csv_database,"wb:UTF-8") do |file|           
        file.write "\xEF\xBB\xBF"        
        csv = CSV.generate_line(@HEADER,@@CSV_OPTS )
        file.write csv
        self.order(:id).find_each do |obj|          
          row = [
              obj.russian_phrase,
              obj.english_phrase,
              obj.sound,
              obj.prev_phrase,
              obj.next_phrase,
              obj.prev_russian_phrase, 
              obj.next_russian_phrase,
              obj.the_number_of_str,
              obj.added_at,
              obj.file_path,
              obj.created_at.to_i,
              obj.id
          ]
          yield(obj) if block_given?                    
          file.write CSV.generate_line(row,@@CSV_OPTS )
        end
      end
    end
  end
end
