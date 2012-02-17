require 'test/unit'
require 'yargi'

module Yargi
  class EdgeSetTest < Test::Unit::TestCase

    def setup
      @graph = Yargi::Digraph.new
      @s1, @s2 = @graph.add_n_vertices(2)
      @graph.connect(@s1, @s2, {:label => 'a'})
      @graph.connect(@s2, @s1, {:label => 'b'})
    end

    def test_source=
      @graph.edges.source=@s1
      assert @graph.edges.length==2
      assert @s2.out_edges.empty?
      assert @s2.in_edges.length==1
      assert @s1.out_edges.length==2
      assert @s1.in_edges.length==1
    end

    def test_target=
      @graph.edges.target=@s1
      assert @graph.edges.length==2
      assert @s2.in_edges.empty?
      assert @s2.out_edges.length==1
      assert @s1.out_edges.length==1
      assert @s1.in_edges.length==2
    end

  end
end