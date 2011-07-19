module Yargi
  
  #
  # Predicate for graph elements.
  #
  # The following automatic conversions apply on Ruby standard classes
  # when using predicates (see to_predicate in particular):
  # [Predicate] itself
  # [Module] TagPredicate
  # [Proc] LambdaPredicate
  # [TrueClass, NilClass] TruePredicate
  # [FalseClass] FalsePredicate
  # [otherwise] an ArgumentError is raised.
  #
  class Predicate
    
    class << self
      # Builds a 'what and block' predicate, according the automatic conversions
      # descibed above.
      def to_predicate(what=nil, &block)
        (what, block = block, nil) if what.nil?
        p = case what
          when Predicate
            what
          when Module
            TagPredicate.new(what)
          when Proc
            LambdaPredicate.new(&what)
          when TrueClass, NilClass
            ALL
          when FalseClass
            NONE
          when Integer
            IndexPredicate.new(what)
          else
            raise ArgumentError, "Unable to convert #{what} to a predicate"
        end
        if block
          p & LambdaPredicate.new(&block)
        else
          p
        end
      end
    end
  
    # Builds a 'self and right' predicate
    def &(right)
      AndPredicate.new(*[self, Predicate.to_predicate(right)])
    end
    
    # Builds a 'self or right' predicate
    def |(right)
      OrPredicate.new(*[self, Predicate.to_predicate(right)])
    end
    
    # Builds a 'not(self)' predicate
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
  
  # Index predicate
  class IndexPredicate < Predicate
    
    def initialize(index)
      @index = index 
    end
    
    def ===(elm)
      elm.index == @index
    end
    
    def inspect
      "elm.index == #{index}"
    end
    
  end # class IndexPredicate
  
  class Predicate
    
    # Predicates that always return true
    ALL = TruePredicate.new
  
    # Predicates that always return false
    NONE = FalsePredicate.new
  
  end # class Predicate
  
end