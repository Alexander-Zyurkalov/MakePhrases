# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module SNEnglish 
  class UsersEnglishWord < ApplicationRecord
    belongs_to :user
    belongs_to :english_word
  end
end
