$LOAD_PATH.push 'D:/Personal files/Alex/English/ruby/MakePhrases/lib' 


require "snenglish"
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'dbuser',
  password: 'dbuser',
  database: 'english_test'
)



describe SNEnglish::WordMatchingTask do
  
  before(:all) do
    require 'fileutils'
    
    @csv_database = 'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/SrtPhraseMatchingTask/database.csv'
    @words =        'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/SrtPhraseMatchingTask/words.csv'
    @phrases =      'D:/Personal files/Alex/English/ruby/MakePhrases/spec/data/SrtPhraseMatchingTask/phrases.csv'      
    
    SNEnglish::WordMatchingTask.delete_all
    SNEnglish::SrtPhraseMatchingTask.delete_all
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

  it "should add the phrase 'The Vuelta a Espana is a major annual event in which sport?' to mathching tasks" do            
    major = SNEnglish::EnglishWord.find_by(english: 'major')    
    expect( major.word_phrase_relations.count(:id)).to be 0
    event = SNEnglish::EnglishWord.find_by(english: 'event')    
    expect( event.word_phrase_relations.count(:id)).to be 2
    expect( event.word_phrase_relations.where(showed: true).count(:id)).to be 1
    english_phrase = SNEnglish::SrtPhrase.find_by(
      english_phrase: 'The Vuelta a Espana is a major annual event in which sport?')
    expect(english_phrase.srt_phrase_matching_task).to_not be nil
  end    
  
  it "should find that the phrase is related to words \"major\" and \"event\"" do
    english_phrase = SNEnglish::SrtPhrase.find_by(
      english_phrase: 'The Vuelta a Espana is a major annual event in which sport?')
    major = english_phrase.english_words.find_by(english: 'major')
    event = english_phrase.english_words.find_by(english: 'event')
    expect(major).to be nil
    expect(event).to_not be nil
    SNEnglish::SrtPhraseMatchingTask.do_matching_for_all    
    major = english_phrase.english_words.find_by(english: 'major')    
    expect(major).to_not be nil
  end
#  it "should mark phrases related to \"major\" which already shown" do       
#    major = SNEnglish::EnglishWord.find_by(english: 'major')    
#    expect( major.word_phrase_relations.where(showed: true).count(:id)).to be 1    
#  end
    
      
  # TODO check repeated loading also
    
  
end


