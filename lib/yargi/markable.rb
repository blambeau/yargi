module Yargi
  
  #
  # Allows users to put its own marks on graph elements. A Hash-like API for setting 
  # and getting these marks is provided through <tt>[]</tt> and <tt>[]=</tt>. When a 
  # Symbol object is used as a mark key (and provided it does'nt lead to a name 
  # collision), accessors are automatically defined as singleton methods (without 
  # creating an instance variable however).
  #
  module Markable

    # Tag this element with some modules
    def tag(*modules)
      modules.each {|mod| self.extend(mod)}
    end
    
    # Checks if a given mark exists
    def has_mark?(key)
      @marks and @marks.has_key?(key)
    end

    # Returns the mark value installed under _key_. Returns nil if no such mark.
    def get_mark(key)
      @marks ? @marks[key] : nil; 
    end
    alias :[] :get_mark
    
    # Sets a key/value pair as a mark. Overrides previous mark value if _key_ is
    # already in used. Automatically creates accessors if _key_ is a Symbol and such
    # methods do not already exists.
    def set_mark(key, value)
      @marks = {} unless @marks
      @marks[key] = value
      if Symbol===key and not(self.respond_to?(key) or self.respond_to?("#{key}=".to_sym))
        instance_eval %Q{
          class << self
            def #{key}() @marks[:#{key}]; end
            def #{key}=(value) @marks[:#{key}]=value; end
          end
        }
      end
    end
    alias :[]= :set_mark
    
    # Add all marks provided by a Hash instance _marks_.
    def add_marks(marks=nil)
      marks.each_pair {|k,v| self[k]=v} if marks
      if block_given?
        result = yield self
        add_marks(result) if Hash===result
      end
    end
    alias :merge_marks :add_marks
    
    # Converts this Markable to a Hash. When _nonil_ is true, nil mark values
    # do not lead to hash entries.
    def to_h(nonil=true)
      return {} unless @marks
      marks = @marks.dup
      if nonil
        marks.delete_if {|k,v| v.nil?}
      end
      marks
    end
    
  end # module Markable
  
end