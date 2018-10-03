$LOAD_PATH.push 'D:/Personal files/Alex/English/ruby/MakePhrases/lib' 


require "snenglish"
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'dbuser',
  password: 'dbuser',
  database: 'english_test'
)

    

     
describe 'SrtPhrase' do
  context "Loading data to the database" do
    before(:all) do
      SNEnglish::SrtPhraseMatchingTask.delete_all
      SNEnglish::WordMatchingTask.delete_all
      SNEnglish::WordPhraseRelation.delete_all
      SNEnglish::SrtPhrase.delete_all      
      SNEnglish::EnglishWord.delete_all  
      @csv_database =  'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/SrtPhrase/database.csv'
      @english_phrase = 'electron traveling forwards through time'  
      $additional_csv = 'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/SrtPhrase/additional.csv'
    end
    it "shoud contain all rows from CSV at the first loading" do            
      require 'fileutils'
          

      FileUtils.cp (@csv_database+'.test'), @csv_database      
      
      SNEnglish::SrtPhrase.load_csv(@csv_database, last_comparing: '180114')
      count_of_entries_in_database = SNEnglish::SrtPhrase.count(:id)
      csv = CSV.open(  @csv_database, "rb"  )
      csv_count = csv.count-1
      expect( count_of_entries_in_database ).to eq csv_count      
      
      phrase_in_db = SNEnglish::SrtPhrase.find_by(
          :english_phrase => @english_phrase
        ).russian_phrase
      expect( phrase_in_db ).to eql ''
      csv.close
    end
    
    it "shoud contain updated and added rows" do      
      
      CSV.open(  @csv_database+'.new', "wb"  ) do |new_csv|
        new_csv << [
              "RussianPhrase","EnglishPhrase",
              "sound","prevPhrase","nextPhrase",
              "prevRussianPhrase", "nextRussianPhrase",
              "order","date","filePath","created_at",'id'             
            ]
        CSV.foreach(  @csv_database,  quote_char: '"',
                          col_sep: ',',  row_sep: :auto,
                          headers: true, encoding: "bom|utf-8"  ) do |row|
          if row[1] == @english_phrase
            row[0] = '111' 
            row[10] = ''
          end
          new_csv << row
        end
        CSV.foreach( $additional_csv,  quote_char: '"',
                          col_sep: ',',  row_sep: :auto,
                          headers: true, encoding: "bom|utf-8"  ) do |row|          
          new_csv << row
        end
      end      
      
      File.rename(@csv_database+'.new', @csv_database)        
      SNEnglish::SrtPhrase.load_csv(@csv_database, last_comparing: '180114')
      count_of_entries_in_database = SNEnglish::SrtPhrase.count(:id)      
      csv = CSV.open(  @csv_database, "rb"  )      
      csv_count = csv.count-1      
      csv.close
      expect( count_of_entries_in_database ).to eq csv_count
      
      phrase_in_db = SNEnglish::SrtPhrase.find_by(
          :english_phrase => @english_phrase
        ).russian_phrase
      expect( phrase_in_db  ).to eq '111'
      
      FileUtils.rm @csv_database
      FileUtils.rm (@csv_database+'.bak')
    end
    
  end
end

