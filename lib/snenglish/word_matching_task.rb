module SNEnglish
  class WordMatchingTask <MatchingTask
    self.primary_key = :english_word_id
    belongs_to :english_word    

    def do_matching
      self.transaction do
        #regex1 = self.english_word.regex1.gsub('\\w','[[:alpha:]]')
        regex1 = self.english_word.regex1
        #regex1 = ('[[:<:]](' + regex1 + ')[[:>:]]').downcase
        regex1 = ('\\\\b(' + regex1 + ')\\\\b').downcase
#        puts regex1
        sql = <<"SQL"
INSERT IGNORE INTO word_phrase_relations (english_word_id, srt_phrase_id,created_at,updated_at)
  SELECT distinct #{self.english_word_id}, p.id, now(), now()
    FROM srt_phrases p LEFT JOIN word_phrase_relations r 
      ON  p.id = r.srt_phrase_id 
    WHERE (r.english_word_id is null OR r.english_word_id != #{self.english_word_id}) and
          LOWER(p.english_phrase) REGEXP "\\\\b(#{regex1})\\\\b" 
SQL
        
#        puts sql
        
        #st = ApplicationRecord.connection.raw_connection.prepare(sql)        
        ApplicationRecord.connection.execute(sql);
#        puts "================================"
#        puts  st.class
#        st.execute( self.english_word_id, 
#                    self.english_word_id, 
#                    '\\\\b(' + self.english_word.english.downcase + ')\\\\b',
#                    regex1)
#        puts st.affected_rows
#        st.close              
        
#        count_of_shown_phrases = 
#          self.english_word.word_phrase_relations.where(showed: true).count(:id)
        
        

#        # further we should mark all already shown phrases for other words
#        # as shown for this word if we_need_more_phrases_to_show
#        we_need_more_phrases_to_show = false; #count_of_shown_phrases < 3
#        # --------------------
#        self.english_word.
#            word_phrase_relations.
#            where("showed is null or showed = false").
#            each do |word_phrase_relation|
#            
#          we_still_need_more_phrases_to_show = false; #count_of_shown_phrases < 3
#
#          break unless we_still_need_more_phrases_to_show;
#          
#          count_of_where_the_phrase_is_shown = WordPhraseRelation.where(
#                  showed: 1, 
#                  srt_phrase_id: word_phrase_relation.srt_phrase_id
#                ).group(:srt_phrase_id).count[word_phrase_relation.srt_phrase_id]          
#          
#          the_phrase_is_shown_anywhere_else = 
#              count_of_where_the_phrase_is_shown != nil &&
#              count_of_where_the_phrase_is_shown > 0
#
#          the_phrase_can_be_shown_without_confirmation = 
#              the_phrase_is_shown_anywhere_else
#          if the_phrase_can_be_shown_without_confirmation
#            word_phrase_relation.showed = true 
#            word_phrase_relation.save
#            count_of_shown_phrases += 1 
#          end
#            
#        end if we_need_more_phrases_to_show
        # --------------------
        
        self.destroy
      
      end
    end
    
    def self.do_matching_for_all
      self.find_each do |word_matching_task|        
        word_matching_task.do_matching
        yield word_matching_task if block_given?
      end
    end
    
  end 
end
