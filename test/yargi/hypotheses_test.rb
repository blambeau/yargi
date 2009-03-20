require 'test/unit'

module Yargi
  
  # Checks some hypotheses that we make about Ruby 
  class HypothesesTest < Test::Unit::TestCase
    
    def test_method_missing_handles_block_as_expected
      p = Object.new
      def p.say_hello
        who = block_given? ? yield : "anonymous"
        "Hello #{who}"
      end
      o = Object.new
      def o.set_obj(obj)
        @obj = obj
      end
      def o.method_missing(name, *args, &block)
        @obj.send(name, *args, &block)
      end
      assert_equal "Hello anonymous", p.say_hello
      assert_equal "Hello blambeau", p.say_hello {"blambeau"}
      o.set_obj(p)
      assert_equal "Hello anonymous", o.say_hello
      assert_equal "Hello blambeau", o.say_hello {"blambeau"}
    end
    
  end # class HypothesesTest

end
