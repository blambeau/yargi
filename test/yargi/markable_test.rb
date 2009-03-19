require 'test/unit'
require 'yargi'

module Yargi
  class MarkableTest < Test::Unit::TestCase
    
    def setup
      @object = Object.new
      @object.extend Yargi::Markable
    end
    
    def test_mark_set_and_get
      @object["hello"] = "world"
      assert_equal "world", @object["hello"]
      @object["hello"] = "world1"
      assert_equal "world1", @object["hello"]
    end
    
    def test_friendly_methods
      @object[:first] = 1
      assert_equal 1, @object.first
      @object.first = 2
      assert_equal 2, @object.first
    end
    
    def test_it_is_not_intrusive
      @object[:merge_marks] = 1
      assert_nothing_raised do
        @object.merge_marks "hello" => "marks"
      end
      assert_equal 1, @object[:merge_marks]
      assert_equal "marks", @object["hello"]
    end
    
  end
end
