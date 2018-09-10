$LOAD_PATH.push 'D:/Personal files/Alex/English/ruby/MakePhrases/lib' 


require "snenglish"
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'root',
  password: '',
  database: 'english_test'
)


describe 'EnglishWord' do
  context "Loading data to the database" do
    before(:all) do
      require 'fileutils'
      @words =  'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/EnglishWord/words.csv'
      @additional_words = 'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/EnglishWord/additional_words.csv'
      @search_in_data = 'caveat'  

      SNEnglish::WordMatchingTask.delete_all
      SNEnglish::SrtPhraseMatchingTask.delete_all
      SNEnglish::WordPhraseRelation.delete_all
      SNEnglish::SrtPhrase.delete_all      
      SNEnglish::EnglishWord.delete_all   
    end
    
    it "shoud contain all rows from CSV at the first loading" do
      FileUtils.cp (@words+'.test'), @words
      SNEnglish::EnglishWord.load_csv(@words, last_comparing: '180114')
      expect(SNEnglish::WordMatchingTask.count(:english_word_id)).to be 0
      count_of_entries_in_database = SNEnglish::EnglishWord.count(:id)
      csv = CSV.open(  @words, "rb"  )
      csv_count = csv.count-1
      expect( count_of_entries_in_database ).to eq csv_count      
      
      phrase_in_db = SNEnglish::EnglishWord.find_by(
          :english => @search_in_data
        ).russian
      expect( phrase_in_db ).to eq 'предостережение'
      csv.close
    end
    
    it "shoud contain updated and added rows" do      
      
      CSV.open(  @words+'.new', "wb"  ) do |new_csv|
        new_csv << [
                "english","russian","sound","picture","example","prevPhrase1",
                "EnglishPhrase1","nextPhrase1","prevRussianPhrase1",
                "RussianPhrase1","nextRussianPhrase1","sound1","prevPhrase2",
                "EnglishPhrase2","nextPhrase2","prevRussianPhrase2",
                "RussianPhrase2","nextRussianPhrase2","sound2","prevPhrase3",
                "EnglishPhrase3","nextPhrase3","prevRussianPhrase3",
                "RussianPhrase3","nextRussianPhrase3",
                "sound3","count","regex1","date","created_at","id"
              ] 
        CSV.foreach(  @words,  quote_char: '"',
                          col_sep: ',',  row_sep: :auto,
                          headers: true, encoding: "bom|utf-8"  ) do |row|
          if row[0] == @search_in_data
            row[1] = '1предостережение1' 
            row[29] = ''
          end
          new_csv << row
        end
        CSV.foreach( @additional_words,  quote_char: '"',
                          col_sep: ',',  row_sep: :auto,
                          headers: true, encoding: "bom|utf-8"  ) do |row|                    
          new_csv << row
        end
      end      
      
      File.rename(@words+'.new', @words)        
      SNEnglish::EnglishWord.load_csv(@words, last_comparing: '180114')
      count_of_entries_in_database = SNEnglish::EnglishWord.count(:id)      
      csv = CSV.open(  @words, "rb"  )      
      csv_count = csv.count-1      
      csv.close
      expect( count_of_entries_in_database ).to eq csv_count
      expect(SNEnglish::WordMatchingTask.count(:english_word_id)).to be 13
      
      phrase_in_db = SNEnglish::EnglishWord.find_by(
          :english => @search_in_data
        ).russian
      
      expect( phrase_in_db  ).to eq '1предостережение1'                    
      #FileUtils.rm @words
      #FileUtils.rm (@words+'.bak')
    end
    
  end
end

