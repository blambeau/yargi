module Yargi
  
  # Predicate for graph elements.
  class Predicate
    
    # When _what_ is not nil, converts it to a predicate (typically a module).
    # Otherwise, a block is expected, which is converted to a LambdaPredicate.
    # Otherwise, returns ALL.
    def self.to_predicate(what=nil, &block)
      if not(what.nil?)
        case what
          when Predicate
            what
          when Module
            TagPredicate.new(what)
          when Proc
            LambdaPredicate.new(what)
          when TrueClass
            ALL
          when FalseClass
            NONE
          else
            raise ArgumentError, "Unable to convert #{what} to a predicate"
        end
      elsif block_given?
        LambdaPredicate.new &block
      else
        ALL
      end
    end
  
    # Builds a AND predicate
    def &(right)
      AndPredicate.new(*[self, Predicate.to_predicate(right)])
    end
    
    # Builds a OR predicate
    def |(right)
      OrPredicate.new(*[self, Predicate.to_predicate(right)])
    end
    
    # Negates this predicate
    def not()
      NotPredicate.new(self)
    end
    
  end # class Predicate

  # Decorates _true_ as a predicate
  class TruePredicate < Predicate
    
    # Always returns true
    def ===(elm)
      true
    end
    
    # Returns 'true'
    def inspect
      "true"
    end
    
  end # class TruePredicate

  # Decorates _false_ as a predicate
  class FalsePredicate < Predicate
    
    # Always returns false
    def ===(elm)
      false
    end
    
    # Returns 'false'
    def inspect
      "false"
    end
    
  end # class TruePredicate

  # Decorates a module instance as a predicate
  class TagPredicate < Predicate
    
    # Creates a Tag predicate
    def initialize(mod)
      raise ArgumentError, "Module expected, #{mod} received" unless Module===mod
      @mod = mod
    end
    
    # Predicate implementation
    def ===(elm)
      @mod===elm
    end
    
    # Helps debugging predicates
    def inspect
      "is_a?(#{@mod})"
    end
    
  end # class TagPredicate
  
  # Decorates a block as a predicate
  class LambdaPredicate < Predicate
    
    # Creates a Tag predicate
    def initialize(&block)
      raise ArgumentError, "Block of arity 1 expected" unless (block and block.arity==1)
      @block = block
    end
    
    # Predicate implementation
    def ===(elm)
      @block.call(elm)
    end
    
    # Helps debugging predicates
    def inspect
      "lambda{...}"
    end
    
  end # class LambdaPredicate
  
  # Negates another predicate
  class NotPredicate < Predicate
    
    # Creates a 'not(negated)' predicate
    def initialize(negated)
      @negated = Predicate.to_predicate(negated)
    end
    
    # Predicate implementation
    def ===(elm)
      not(@negated === elm)
    end
    
    # Helps debugging predicates
    def inspect
      "not(#{@negated})"
    end
    
  end # class NotPredicate
  
  # Conjunction predicate
  class AndPredicate < Predicate
    
    # Builds a AND predicate
    def initialize(*anded)
      raise ArgumentError, "Predicates expected" unless anded.all?{|p| Predicate===p}
      @anded = anded
    end
    
    # Predicate implementation
    def ===(elm)
      @anded.all?{|p| p===elm}
    end
    
    # Pushes _right_ in the anded array
    def &(right)
      @anded << Predicate.to_predicate(right)
      self
    end
    
    # Helps debugging predicates
    def inspect
      @anded.inject('') do |memo,p|
        if memo.empty?
          p.inspect
        else
          "#{memo} and #{p.inspect}"
        end
      end
    end
    
  end # class AndPredicate
  
  # Disjunction predicate
  class OrPredicate < Predicate
    
    # Builds a OR predicate
    def initialize(*ored)
      raise ArgumentError, "Predicates expected" unless ored.all?{|p| Predicate===p}
      @ored = ored
    end
    
    # Predicate implementation
    def ===(elm)
      @ored.any?{|p| p===elm}
    end
    
    # Pushes _right_ in the ored array
    def |(right)
      @ored << Predicate.to_predicate(right)
      self
    end
    
    # Helps debugging predicates
    def inspect
      @ored.inject('') do |memo,p|
        if memo.empty?
          p.inspect
        else
          "#{memo} or #{p.inspect}"
        end
      end
    end
    
  end # class OrPredicate
  
  class Predicate
    
    # Predicates that always return true
    ALL = TruePredicate.new
  
    # Predicates that always return false
    NONE = FalsePredicate.new
  
  end # class Predicate
  
end