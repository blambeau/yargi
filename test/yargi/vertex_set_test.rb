require 'test/unit'
require 'yargi'

module Yargi
  
  class VertexSetTest < Test::Unit::TestCase
    
    module Center; end
    module AtOne; end
    module AtTwo; end
  
    def setup
      @star = Yargi::Digraph.new
      @center = @star.add_vertex(Center)
      @atone = @star.add_n_vertices(10, AtOne)
      @attwo = @star.add_n_vertices(10, AtTwo)
      @star.connect(@center, @atone)
      @atone.zip(@attwo).each do |pair|
        @star.connect(pair[0], pair[1])
      end
      #puts @star.to_dot
    end
    
    def test_in_and_out_edges
      assert_equal [], VertexSet[@center].in_edges
      assert_equal @atone.in_edges, VertexSet[@center].out_edges
      assert_equal @attwo.in_edges, @atone.out_edges
    end
    
    def test_in_and_out_edges_no_duplicate
      @star.connect(@atone, @atone)
      assert_equal @atone.in_edges, @atone.in_edges.uniq
      assert_equal @atone.out_edges, @atone.out_edges.uniq
      assert_equal @atone, VertexSet[@center].out_edges.target
      sortproc = Kernel.lambda {|v1,v2| v1.index <=> v2.index}
      assert_equal (@atone+@attwo).sort(&sortproc), @atone.out_edges.target.sort(&sortproc)
      assert_equal @atone.sort(&sortproc), @atone.out_edges.source.sort(&sortproc)
      assert_equal (@atone+[@center]).sort(&sortproc), @atone.in_edges.source.sort(&sortproc)
    end
    
  end # class VertexSetTest
  
end