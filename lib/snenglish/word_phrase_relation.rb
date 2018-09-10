
module SNEnglish   
   
  class WordPhraseRelation < SNEnglish::Base
    
    
    @HEADER = [
                "word","russian","phrase","RussianPhrase","show","date","count",
                "created_at",'id','file_path'
              ]  
    
    belongs_to :english_word
    belongs_to :srt_phrase
    
    
    def self.was_updated?(rowHash,the_row_was_created)
      if the_row_was_created &&
              (word_phrase_relation = 
                  self.joins(:english_word, :srt_phrase).find_by(
                    english_words: {english: rowHash['word']}, 
                    srt_phrases: { english_phrase: rowHash['phrase']})
              ) != nil        
        rowHash['id'] = word_phrase_relation.id 
        true        
      elsif the_row_was_created
        false
      else
        true
      end
    end
    
    def set_attrs(rowHash)      
      self.english_word = SNEnglish::EnglishWord.find_by(
        :english => rowHash['word']   )
      self.srt_phrase = SNEnglish::SrtPhrase.find_by(
        :english_phrase => rowHash['phrase'] )
      self.showed = nil
      #puts "set_attrs"
      self.showed = true  if rowHash['show'] == '1' || rowHash['show'] == 1
      if rowHash['show'] == '0' || rowHash['show'] == 0
        self.showed = false 
        #puts self.srt_phrase.english_phrase
      end
      all_links_were_found = 
        self.english_word != nil  &&  self.srt_phrase != nil   # answers to 
                                                               # the load_csv function 
                                                               # that it can be saved
      all_links_were_found
    end
    def add_columns_to_csv(row)
      
      if row.count < 9 && self.id != nil
        row.push self.created_at.to_i 
        row.push self.id
      elsif row.count < 9 && self.id == nil
        row.push '' 
        row.push ''
      elsif row.count < 10 
        row.push self.srt_phrase.file_path
      else 
        row[-3] = self.created_at.to_i
        row[-2] = self.id    
        row[-1] = self.srt_phrase.file_path
      end
      
    end
    def self.load_csv(csv_database, last_comparing: '170101')
      super csv_database, last_comparing: last_comparing
    end    
    
    def self.save_csv(csv_database)
      
      require 'fileutils'
      FileUtils.cp csv_database, (csv_database+'.bak')
      File.open(csv_database,"wb:UTF-8") do |file|           
        file.write "\xEF\xBB\xBF"        
        csv = CSV.generate_line(@HEADER,@@CSV_OPTS )
        file.write csv

        sql = <<SQL
select 
    english as word, 
    russian,
    english_phrase as phrase,
    russian_phrase as RussianPhrase,
    showed as showed,
    english_words.added_at as date,
    count_id as count,
    word_phrase_relations.created_at,
    word_phrase_relations.id,
    srt_phrases.file_path as file_path
from word_phrase_relations join english_words on word_phrase_relations.english_word_id = english_words.id
    join srt_phrases  on srt_phrases.id = word_phrase_relations.srt_phrase_id 
    left join shown_phrases on english_words.id = shown_phrases.english_word_id
WHERE showed is null or showed = true
order by english_words.added_at, word_phrase_relations.created_at, english 
SQL
        self.connection.execute(sql).each do |row|
          #puts row.to_hash
          row[6] = 0 if row[6].nil?
          row[7] = row[7].to_i
          file.write CSV.generate_line(row,@@CSV_OPTS )
          yield(row) if block_given?   
        end
      end
        
    end    
    
  end
  
end
