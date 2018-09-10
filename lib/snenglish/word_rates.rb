
module SNEnglish   
  
  
  class WordRate < SNEnglish::Base
   
    
    @HEADER = [
                "number_of","word","part_of_speech","number_of_files","id"
              ]    
    
    def add_columns_to_csv(row)      
      if row.count < 5                
        row.push self.id        
      else          
        row[-1] = self.id             
      end      
    end   
    
    
    def set_attrs(rowHash)
      #"number_of","word","part_of_speech","number_of_files"
      self.number_of = rowHash["number_of"]        
      self.word  = rowHash["word"]
      self.part_of_speech    = rowHash["part_of_speech"]
      self.number_of_files  = rowHash["number_of_files"]      
      true
    end         
    
  end
     
end