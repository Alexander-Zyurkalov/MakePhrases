# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module SNEnglish 
  class ShownPhrase < SNEnglish::Base
    belongs_to :english_word
  end
end
