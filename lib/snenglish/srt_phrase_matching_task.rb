module SNEnglish
  class SrtPhraseMatchingTask <MatchingTask
    self.primary_key = :srt_phrase_id
    belongs_to :srt_phrase
    
#    sql =<<SQL
#INSERT IGNORE INTO word_phrase_relations (english_word_id, srt_phrase_id,created_at,updated_at)
#  SELECT distinct w.id, ?, now(), now()
#  FROM (english_words w left JOIN shown_phrases s on w.id = s.english_word_id)
#          LEFT JOIN
#       word_phrase_relations r ON r.english_word_id = w.id AND r.srt_phrase_id = ?
#  WHERE (s.count_id < 3 or s.count_id is null)
#          AND
#        (r.srt_phrase_id is null)
#          AND
#        ( ? REGEXP LOWER(concat('[[:<:]](',w.english,')[[:>:]]')) OR
#          ? REGEXP LOWER(concat('[[:<:]](',replace(w.regex1,'\\w','[[:alpha:]]'),')[[:>:]]')) )
#;      
#SQL
    
    def do_matching
      self.transaction do
        sql =<<SQL
INSERT IGNORE INTO word_phrase_relations (english_word_id, srt_phrase_id,created_at,updated_at)
  SELECT distinct w.id, ?, now(), now()
  FROM (english_words w left JOIN shown_phrases s on w.id = s.english_word_id)
          LEFT JOIN
       word_phrase_relations r ON r.english_word_id = w.id AND r.srt_phrase_id = ?
  WHERE 
        (r.srt_phrase_id is null)
          AND
        ( ? REGEXP LOWER(concat('[[:<:]](',w.english,')[[:>:]]')) OR
          ? REGEXP LOWER(concat('[[:<:]](',replace(w.regex1,'\\w','[[:alpha:]]'),')[[:>:]]')) )
;      
SQL
        st = ApplicationRecord.connection.raw_connection.prepare(sql)
        st.execute( self.srt_phrase_id, 
                    self.srt_phrase_id, 
                    self.srt_phrase.english_phrase.downcase, 
                    self.srt_phrase.english_phrase.downcase )
        st.close   
      
        # further we should mark all words related to the phrase if there has 
        # already been one word related to the phrase
        # --------------------
                
        there_is_a_word_related_to_the_phrase = 
            self.srt_phrase.word_phrase_relations.
            where(showed: true).count(:id) > 0
        self.srt_phrase.word_phrase_relations.
              where("showed is null or showed = false").find_each do |w_p_relation|                      
          shown_phrase = w_p_relation.english_word.shown_phrase
          if shown_phrase == nil || shown_phrase.count_id < 3
            w_p_relation.showed = true
            w_p_relation.save
          end            
        end if there_is_a_word_related_to_the_phrase
        
        # --------------------
        self.destroy;
      end
    end
    
    
    def self.do_matching_for_all      
      
      self.find_each do |srt_phrase_matching_task|        
        srt_phrase_matching_task.do_matching
        yield srt_phrase_matching_task if block_given?      
      end
      
    end 
  end
end
