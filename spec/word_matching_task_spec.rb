$LOAD_PATH.push 'D:/Personal files/Alex/English/ruby/MakePhrases/lib' 


require "snenglish"
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'root',
  password: '',
  database: 'english_test'
)



describe SNEnglish::WordMatchingTask do
  
  before(:all) do
    require 'fileutils'
    
    @csv_database =  'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/WordMatchingTask/database.csv'
    @words = 'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/WordMatchingTask/words.csv'
    @phrases =  'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/WordMatchingTask/phrases.csv'      
    
    SNEnglish::WordMatchingTask.delete_all
    SNEnglish::WordPhraseRelation.delete_all
    SNEnglish::SrtPhrase.delete_all      
    SNEnglish::EnglishWord.delete_all   

    FileUtils.cp (@words+'.test'), @words
    SNEnglish::EnglishWord.load_csv(@words, last_comparing: '180114')
    FileUtils.cp (@csv_database+'.test'), @csv_database
    SNEnglish::SrtPhrase.load_csv(@csv_database, last_comparing: '180114')
    FileUtils.cp (@phrases+'.test'), @phrases
    SNEnglish::WordPhraseRelation.load_csv(@phrases, last_comparing: '180114')

  end
  after(:all) do
    FileUtils.rm @words
    FileUtils.rm @phrases
    FileUtils.rm (@words+'.bak')
    FileUtils.rm (@phrases+'.bak')
    FileUtils.rm @csv_database
    FileUtils.rm (@csv_database+'.bak') 
  end

  it "should match the word \"major\" with few defined phrases "do            
    major = SNEnglish::EnglishWord.find_by(english: 'major')    
    expect( major.word_phrase_relations.count(:id)).to be 0
    event = SNEnglish::EnglishWord.find_by(english: 'event')    
    expect( event.word_phrase_relations.count(:id)).to be 2
    expect( event.word_phrase_relations.where(showed: true).count(:id)).to be 1
    
    SNEnglish::WordMatchingTask.do_matching_for_all
    expect( event.word_phrase_relations.count(:id)).to be 2
    expect( event.word_phrase_relations.where(showed: true).count(:id)).to be 1    
    expect( major.word_phrase_relations.count(:id)).to be 5  
    

  end    
  
  it "should mark phrases related to \"major\" which already shown" do
    
    srt_phrase = SNEnglish::SrtPhrase.find_by(
      english_phrase: 
        'The Vuelta a Espana is a major annual event in which sport?'
    );
    expect( srt_phrase == nil ).to be false
    
    major = SNEnglish::EnglishWord.find_by(english: 'major')    
    expect( major.word_phrase_relations.where(showed: true).count(:id)).to be 3
    
  end
    
      
  # TODO check repeated loading also
    
  
end


