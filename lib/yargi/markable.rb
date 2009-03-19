module Yargi
  
  # Allows users to put marks on Isis components
  module Markable
    
    # User marks
    attr_reader :marks
    
    # Returns a mark installed under a specific key
    def [](key) 
      @marks ? @marks[key] : nil; 
    end
    
    # Sets a mark
    def []=(key, value)
      @marks = {} unless marks
      if value.nil?
        @marks.delete(key)
      else
        @marks[key] = value
        # install a friendly method if a symbol as key
        if Symbol===key and not(self.respond_to?(key))
          instance_eval %Q{
            class << self
              def #{key}() @marks[:#{key}]; end
              def #{key}=(value) @marks[:#{key}]=value; end
            end
          }
        end
      end
    end
      
    # Merge some marks
    def add_marks(marks)
      marks.each_pair {|k,v| self[k]=v}
    end
    alias :merge_marks :add_marks
      
  end # module Markable
  
end