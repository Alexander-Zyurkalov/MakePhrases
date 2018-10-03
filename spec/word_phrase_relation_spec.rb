$LOAD_PATH.push 'D:/Personal files/Alex/English/ruby/MakePhrases/lib' 


require "snenglish"
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'dbuser',
  password: 'dbuser',
  database: 'english_test'
)



describe 'EnglishWord' do
  context "Loading data to the database" do
    before(:all) do
      require 'fileutils'
      @csv_database =  'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/WordPhraseRelation/database.csv'
      @words = 'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/WordPhraseRelation/words.csv'
      @phrases =  'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/WordPhraseRelation/phrases.csv'
      @additional_phrases = 'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/WordPhraseRelation/additional_phrases.csv'
      
      SNEnglish::SrtPhraseMatchingTask.delete_all
      SNEnglish::WordMatchingTask.delete_all
      SNEnglish::WordPhraseRelation.delete_all
      SNEnglish::SrtPhrase.delete_all      
      SNEnglish::EnglishWord.delete_all   
    end
    it "should contain all rows from CSV at the first loading" do            
      
      FileUtils.cp (@words+'.test'), @words
      SNEnglish::EnglishWord.load_csv(@words, last_comparing: '180114')
      FileUtils.cp (@csv_database+'.test'), @csv_database
      SNEnglish::SrtPhrase.load_csv(@csv_database, last_comparing: '180114')
      FileUtils.cp (@phrases+'.test'), @phrases
      SNEnglish::WordPhraseRelation.load_csv(@phrases, last_comparing: '180114')
      count_of_entries_in_database = SNEnglish::WordPhraseRelation.count(:id)            
      relation = SNEnglish::WordPhraseRelation.joins(:english_word, :srt_phrase).find_by(
         english_words: {english: 'fear'}, 
         srt_phrases: {  english_phrase: 'There is great excitement, and there is great anticipation, and a little bit of fear.'  } )
      expect( relation ).not_to be_nil
      expect( relation.showed ).to be false
      expect( count_of_entries_in_database ).to eq 137           
    end
    
    it "should contain updated and added rows" do      
      #SNEnglish::EnglishWord.new(english: 'zinc', russian: 'цинк').save
      SNEnglish::SrtPhrase.new(english_phrase: 'Carbohydrates, proteins, iron, and zinc,').save
      
      CSV.open(  @phrases+'.new', "wb"  ) do |new_csv|
        new_csv << [
                'word','russian','phrase','RussianPhrase','show','date','count',
                "created_at",'id'
              ] 
        CSV.foreach(  @phrases,  quote_char: '"',
                          col_sep: ',',  row_sep: :auto,
                          headers: true, encoding: "bom|utf-8"  ) do |row|
          new_csv << row
        end
        CSV.foreach( @additional_phrases,  quote_char: '"',
                          col_sep: ',',  row_sep: :auto,
                          headers: true, encoding: "bom|utf-8"  ) do |row|                    
          new_csv << row
        end
      end      
      File.rename(@phrases+'.new', @phrases)        
      SNEnglish::WordPhraseRelation.load_csv(@phrases, last_comparing: '180114')
      relation = SNEnglish::WordPhraseRelation.joins(:english_word, :srt_phrase).find_by(
         english_words: {english: 'fear'}, 
         srt_phrases: {  english_phrase: 'There is great excitement, and there is great anticipation, and a little bit of fear.'  } )
      expect( relation ).not_to be_nil
      expect( relation.showed ).to be true
      
      count_of_entries_in_database = SNEnglish::WordPhraseRelation.count(:id)    
      expect( count_of_entries_in_database ).to eq 157
      FileUtils.rm @words
      FileUtils.rm @phrases
      FileUtils.rm (@words+'.bak')
      FileUtils.rm (@phrases+'.bak')

      FileUtils.rm @csv_database
      FileUtils.rm (@csv_database+'.bak')
    end
    
  end
end


