
module SNEnglish   
  
  
  class EnglishWord < SNEnglish::Base
   
    has_one :word_matching_task
    has_many :word_phrase_relations
    has_many :srt_phrases, through: :word_phrase_relations    
    has_one :shown_phrase
#    has_one :word_count
    
    @HEADER = [
                "english","russian","sound","picture","example","prevPhrase1",
                "EnglishPhrase1","nextPhrase1","prevRussianPhrase1",
                "RussianPhrase1","nextRussianPhrase1","sound1","prevPhrase2",
                "EnglishPhrase2","nextPhrase2","prevRussianPhrase2",
                "RussianPhrase2","nextRussianPhrase2","sound2","prevPhrase3",
                "EnglishPhrase3","nextPhrase3","prevRussianPhrase3",
                "RussianPhrase3","nextRussianPhrase3",
                "sound3","count","regex1","date","created_at","id"
              ]    
    
    def self.was_updated?(rowHash,the_row_was_created)    
      was_updated = super rowHash,the_row_was_created
      unless was_updated
        word = self.find_by( english: rowHash['english'] )
        unless word.nil?
          rowHash['id'] = word.id
          was_updated = false
        end
      end
#      if(rowHash['count_id'].nil? || rowHash['count_id'] == "" || rowHash['count_id'] == '0')
#        return true
#      end
      return was_updated
    end
    
    # TODO replace set_attr to attribute and separate status
    def set_attrs(rowHash)
      self.english  = rowHash["english"]
      self.russian  = rowHash["russian"]
      self.sound    = rowHash["sound"]
      self.picture  = rowHash["picture"]
      self.example  = rowHash["example"]
      self.regex1   = rowHash["regex1"]
      self.added_at = rowHash["date"]    
      true
    end    
    def add_columns_to_csv(row)
      
      if row.count < 31        
        row.push self.created_at.to_i 
        row.push self.id
        if !self.word_count.nil?
          row.push obj.word_phrase_relations.count();
        else 
          row.push "0"
        end
      else          
        row[-2] = self.created_at.to_i
        row[-1] = self.id             
      end      

    end       
    def self.load_csv(csv_database, last_comparing: '170101', account_name: nil, user_id:nil)
      #let's do some cheating        
      if account_name.nil? && user_id.nil?         
        account_name = 'alexandr.zyurkalov' if 
            File.expand_path(csv_database) =~ /alex/i              
        account_name = 'milana.zyurkalova'  if 
            File.expand_path(csv_database) =~ /milan/i  
      end
      user = nil
      if !user_id.nil? 
        user = SNEnglish::User.find_by( id: user_id )
      elsif !account_name.nil?
        user = SNEnglish::User.find_by( account_name: account_name )
      end
      
      super csv_database, last_comparing: last_comparing do |row, obj|
        yield row, obj if block_given?
        unless user.nil? || obj.nil?          
          users_english_words = UsersEnglishWords.find_or_create_by(
            user_id: user.id,
            english_word_id: obj.id
          )
          users_english_words.save unless users_english_words.nil?
        end       
      end
    end    
    
    def self.load_csv_with_counting(csv_database, last_comparing: '170101', account_name: nil, user_id:nil)      
      #self.joins(:word_count).load_csv csv_database, last_comparing: last_comparing do |row, obj|
      self.load_csv csv_database, last_comparing: last_comparing do |row, obj|
        yield row, obj if block_given?        
        rowHash = row.to_hash 
        if obj.nil?
          obj = self.find_by( id: rowHash['id'] )
        end
#        obj.word_phrase_relations.
        #RussianPhrase3
        row[23] = obj.nil? || obj.word_phrase_relations.nil? ? 
          0 : 
          obj.word_phrase_relations.count()        
      end
    end 

#    def self.save_csv(csv_database)
#      require 'fileutils'
#      FileUtils.cp csv_database, (csv_database+'.bak')      
#      File.open(csv_database,"wb:UTF-8") do |file|           
#        file.write "\xEF\xBB\xBF"        
#        csv = CSV.generate_line(@HEADER,@@CSV_OPTS )
#        file.write csv
#        self. 
#              joins(:word_phrase_relations, :srt_phrases, :word_counts).
#              group(:id).
#              order(:word_counts => :asc).              
#              find_each do |obj|  
#          #english,russian,sound,
#          #picture,example,
#          #
#          #prevPhrase1,
#          #EnglishPhrase1,nextPhrase1,
#          #prevRussianPhrase1,RussianPhrase1,
#          #nextRussianPhrase1,sound1,
#          #prevPhrase2,EnglishPhrase2,nextPhrase2,
#          #prevRussianPhrase2,RussianPhrase2,nextRussianPhrase2,
#          #sound2,prevPhrase3,EnglishPhrase3,
#          #nextPhrase3,prevRussianPhrase3,
#          #RussianPhrase3,nextRussianPhrase3,
#          #sound3,count,
#          #regex1,date,created_at,id
#          row = [
#            obj.english,
#            obj.russian,
#            obj.sound,
#            obj.picture,
#            obj.example,
#            
#            obj.srt_phrase.
#          ]
#          
##        self.order(:id).find_each do |obj|          
##          row = [
##              obj.russian_phrase,
##              obj.english_phrase,
##              obj.sound,
##              obj.prev_phrase,
##              obj.next_phrase,
##              obj.prev_russian_phrase, 
##              obj.next_russian_phrase,
##              obj.the_number_of_str,
##              obj.added_at,
##              obj.file_path,
##              obj.created_at.to_i,
##              obj.id
##          ]
#          yield(obj) if block_given?                    
#          file.write CSV.generate_line(row,@@CSV_OPTS )
#        end
#      end
#    end
    
    def update_tasks
      if self.word_matching_task == nil
        self.word_matching_task = WordMatchingTask.new( english_word_id: self.id)
        self.word_matching_task.save
      end
    end
  end
end