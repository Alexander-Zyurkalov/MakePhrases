
module SNEnglish 
  class User < ApplicationRecord
    has_many :english_words, through: :users_english_words
  end
end
