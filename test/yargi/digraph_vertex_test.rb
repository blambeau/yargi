require 'test/unit'
require 'yargi'

module Yargi
  class Digraph
    
    class VertexTest < Test::Unit::TestCase
      
      module Center; end
      module AtOne; end
      module AtTwo; end
  
      # Builds the star graph under @star
      def setup
        @star = Yargi::Digraph.new
        @center = @star.add_vertex(Center)
        @atone = @star.add_n_vertices(10, AtOne)
        @attwo = @star.add_n_vertices(10, AtTwo)
        @center_to_one = @star.connect(@center, @atone)
        @one_to_two = @atone.zip(@attwo).collect do |pair|
          @star.connect(pair[0], pair[1])
        end
        @one_to_two = VertexSet.new(@one_to_two)
      end
      
      def test_in_and_out_edges
        assert_equal EdgeSet[], @center.in_edges
        assert_equal @center_to_one, @center.out_edges
        assert_equal @center_to_one, @atone.collect{|v| v.in_edges}.flatten
      end
      
      def test_in_adjacent
        @atone.each {|v| assert_equal VertexSet[@center], v.in_adjacent}
        @atone.each {|v| assert_equal VertexSet[@center], v.in_adjacent(Center)}
        @atone.each {|v| assert_equal VertexSet[], v.in_adjacent(AtOne)}
        assert_equal VertexSet[@center], @atone.in_adjacent
        assert @atone.in_adjacent(AtOne).empty?
        assert_equal VertexSet[@center], @atone.in_adjacent(Center)
      end
      
      def test_out_adjacent
        @atone.each_with_index {|v,i| assert_equal @attwo[i,1], v.out_adjacent}
        @atone.each_with_index {|v,i| assert_equal @attwo[i,1], v.out_adjacent(AtTwo)}
        @atone.each_with_index {|v,i| assert_equal VertexSet[], v.in_adjacent(AtOne)}
        assert_equal @attwo, @atone.out_adjacent
        assert @atone.out_adjacent(AtOne).empty?
        assert_equal @attwo, @atone.out_adjacent(AtTwo)
      end
      
      def test_adjacent
        assert_equal @atone, @center.adjacent
        assert_equal (@attwo+[@center]).sort, @atone.adjacent.sort
        assert_equal @atone.sort, @attwo.adjacent.sort
        assert_equal @star.vertices, (@atone+[@center]).adjacent.sort
        assert_equal @atone, (@atone+[@center]).adjacent(AtOne).sort
      end
      
    end # class VertexTest
    
  end
end