require 'test/unit'
require 'yargi'

module Yargi
  class MarkableTest < Test::Unit::TestCase
    
    def setup
      @object = Object.new
      @object.extend Yargi::Markable
    end
    
    def test_mark_set_and_get
      @object.set_mark("hello", "world")
      assert_equal "world", @object.get_mark("hello")
      @object.set_mark("hello", "world1")
      assert_equal "world1", @object.get_mark("hello")
    end
    
    def test_mark_set_and_get_though_hash_api
      @object["hello"] = "world"
      assert_equal "world", @object["hello"]
      @object["hello"] = "world1"
      assert_equal "world1", @object["hello"]
    end
    
    def test_friendly_methods
      @object.set_mark(:first, 1)
      assert_equal 1, @object.first
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
    
    def test_to_h
      @object.set_mark(:me, "blambeau")
      @object.add_marks(:hello => "world", :who => "yarvi", :nil => nil)
      expected = {:me => "blambeau", :hello => "world", :who => "yarvi", :nil => nil}
      assert_equal expected, @object.to_h(false)
      expected = {:me => "blambeau", :hello => "world", :who => "yarvi"}
      assert_equal expected, @object.to_h(true)
      expected = {:me => "blambeau", :hello => "world", :who => "yarvi"}
      assert_equal expected, @object.to_h()
    end
    
  end
end
