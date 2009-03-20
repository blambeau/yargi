require 'test/unit'
require 'yargi'

module Yargi
  class ElementSetTest < Test::Unit::TestCase
    
    def test_flatten
      e = ElementSet[ElementSet[1, 2, 3], ElementSet[4, 5, 6]]
      assert_equal ElementSet[1, 2, 3, 4, 5, 6], e.flatten

      e = EdgeSet[EdgeSet[1, 2, 3], EdgeSet[4, 5, 6], 7]
      assert EdgeSet===e
      assert_equal EdgeSet[1, 2, 3, 4, 5, 6, 7], e.flatten
    end
    
  end
end