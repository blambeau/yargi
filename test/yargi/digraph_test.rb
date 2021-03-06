require 'test/unit'
require 'yargi'

module Yargi
  class DigraphTest < Test::Unit::TestCase

    module Until; end
    module If; end

    # Creates a digraph instance under @digraph
    def setup
      @digraph = Yargi::Digraph.new
    end

    def test_to_vertices
      untils = @digraph.add_n_vertices(5, Until)
      ifs = @digraph.add_n_vertices(5, If)
      assert_equal [untils[0]], @digraph.send(:to_vertices, untils[0])
      assert_equal [untils[0], untils[1]], @digraph.send(:to_vertices, [untils[0], untils[1]])
      assert_equal [untils[0], untils[1]], @digraph.send(:to_vertices, untils[0], untils[1])
      assert_equal untils, @digraph.send(:to_vertices, Until)
      assert_equal ifs, @digraph.send(:to_vertices, If)
      assert_equal (untils+ifs).sort, @digraph.send(:to_vertices, [Until, If])
      assert_equal (untils+ifs).sort, @digraph.send(:to_vertices, Until, If)
      assert_equal (untils+ifs).sort, @digraph.send(:to_vertices, [Until, If, untils[0]])
      assert_equal (untils+ifs).sort, @digraph.send(:to_vertices, Until, If, untils[0])
    end

    def test_to_edges
      untils = @digraph.add_n_vertices(5, Until)
      ifs = @digraph.add_n_vertices(5, If)
      untils_to_ifs = @digraph.connect(untils, ifs)
      ifs_to_untils = @digraph.connect(ifs, untils)
      assert_equal [untils_to_ifs[0]], @digraph.send(:to_edges, untils_to_ifs[0])
      assert_equal [untils_to_ifs[0], untils_to_ifs[1]], @digraph.send(:to_edges, untils_to_ifs[0], untils_to_ifs[1])
      assert_equal [untils_to_ifs[0], untils_to_ifs[1]], @digraph.send(:to_edges, [untils_to_ifs[0], untils_to_ifs[1]])
      assert_equal @digraph.edges, @digraph.send(:to_edges, untils_to_ifs, ifs_to_untils)
      assert_equal untils_to_ifs, @digraph.send(:to_edges, Proc.new{|e| Until===e.source})
      assert_equal ifs_to_untils, @digraph.send(:to_edges, Proc.new{|e| If===e.source})
    end

#    def test_to_dot_attributes
#      hash = {:label => 'hello', :who => 'blambeau'}
#      assert_equal 'label="hello" who="blambeau"', @digraph.send(:to_dot_attributes, hash)
#      hash = {:label => 'hello', :style => ['filled', 'rounded']}
#      assert_equal 'label="hello" style="filled, rounded"', @digraph.send(:to_dot_attributes, hash)
#      hash = {:label => 'hello', :pos => [[12, 14], [15, 17]]}
#      assert_equal 'label="hello" pos="12,14 15,17"', @digraph.send(:to_dot_attributes, hash)
#    end

    def test_extend_returns_self_hypothese
      assert_equal self, self.extend(Until)
    end

    def test_vertices
      v1 = @digraph.add_vertex({:kind => :point})
      v2 = @digraph.add_vertex({:kind => :point})
      v3 = @digraph.add_vertex({:kind => :end})
      assert_equal :point, v1.kind
      assert_equal :end, v3.kind
      assert_equal VertexSet[v1, v2, v3], @digraph.vertices
      assert_equal v1, @digraph.vertices[0]
      assert_equal VertexSet[v1], @digraph.vertices {|v| v.index==0}
      assert_equal VertexSet[v1, v3], @digraph.vertices {|v| v.index==0 or v.index==2}
      assert_equal VertexSet[v1, v2], @digraph.vertices {|v| v[:kind]==:point}
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_vertices_with_mods
      untils = @digraph.add_n_vertices(5, Until)
      ifs = @digraph.add_n_vertices(5, If)
      assert_equal untils, @digraph.vertices(Until)
      assert_equal ifs, @digraph.vertices(If)
      assert_equal (untils+ifs), @digraph.vertices(Yargi::NONE|Until|If)
    end

    def test_vertices_with_both
      untils = @digraph.add_n_vertices(5, Until)
      ifs = @digraph.add_n_vertices(5, If)
      assert_equal(VertexSet[@digraph.vertices[0]], @digraph.vertices(Until) do |v|
        v.index==0
      end)
      assert_equal(VertexSet[], @digraph.vertices(If) do |v|
        v.index==0
      end)
    end

    def test_module_extended_vertices
      v1 = @digraph.add_vertex(Until)
      v2 = @digraph.add_vertex(If)
      assert Until===v1
      assert If===v2
      assert_equal VertexSet[v1], @digraph.vertices {|v| Until===v}
      assert_equal VertexSet[v2], @digraph.vertices {|v| If===v}
    end

    def test_tag
      v1, v2 = @digraph.add_n_vertices(2)
      v1.tag(Until)
      v2.tag(If, Until)
      assert Until===v1
      assert If===v2 and Until===v2
    end

    def test_edges
      v1, v2, v3 = @digraph.add_n_vertices(3)
      e12, e23, e32, e21 = @digraph.connect_all([v1, v2], [v2, v3], [v3, v2], [v2, v1])
      assert_equal EdgeSet[e12, e23], @digraph.edges {|e| e.index<=1}
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_each_vertex
      v1, v2, v3 = @digraph.add_n_vertices(3)
      seen = []
      @digraph.each_vertex {|v| seen << v}
      assert_equal [v1, v2, v3], seen
    end

    def test_each_vertex_with_filter
      v1, v2, v3, v4, v5 = @digraph.add_n_vertices(5)
      seen = []
      filter = Yargi.predicate {|elm| elm.index<3}
      @digraph.each_vertex(filter) {|v| seen << v}
      assert_equal [v1, v2, v3], seen
      seen = []
      filter = Yargi.predicate {|elm| elm.index>=3}
      @digraph.each_vertex(filter) {|v| seen << v}
      assert_equal [v4, v5], seen
    end

    def test_each_edge
      v1, v2, v3 = @digraph.add_n_vertices(3)
      edges = @digraph.connect_all([v1, v2], [v2, v3], [v3, v2], [v2, v1])
      seen = []
      @digraph.each_edge {|e| seen << e}
      assert_equal edges, seen
    end

    def test_add_vertex
      v1 = @digraph.add_vertex({:style => :begin})
      assert_not_nil v1
      assert_equal @digraph, v1.graph
      assert_equal :begin, v1[:style]
      assert_equal VertexSet[v1], @digraph.vertices
      assert_equal 0, v1.index

      v2 = @digraph.add_vertex({:style => :end})
      assert_not_nil v2
      assert_equal :end, v2[:style]
      assert_equal VertexSet[v1, v2], @digraph.vertices
      assert_equal 0, v1.index
      assert_equal 1, v2.index
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_add_n_vertices
      v1, v2, v3 = @digraph.add_n_vertices(3, {:hello => "world"})
      assert_equal VertexSet[v1, v2, v3], @digraph.vertices
      assert_equal [0, 1, 2], [v1.index, v2.index, v3.index]
      v1[:hello] = "world1"
      v2[:hello] = "world2"
      v3[:hello] = "world3"
      assert_equal ["world1", "world2", "world3"], @digraph.vertices.collect{|v| v[:hello]}
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_add_n_vertices_with_block
      vertices = @digraph.add_n_vertices(5, Until) do |v,i|
        v.set_mark(:mark, i)
      end
      vertices.each_with_index do |v,i|
        assert_equal i, v.mark
        assert Until===v
      end
      assert_equal [0, 1, 2, 3, 4], vertices.get_mark(:mark)
    end

    def test_connect
      v1, v2 = @digraph.add_n_vertices(2)
      edge = @digraph.connect(v1, v2, {:label => "hello"})
      assert_equal @digraph, edge.graph
      assert_not_nil edge
      assert_equal 0, edge.index
      assert_equal "hello", edge[:label]
      assert_equal v1, edge.source
      assert_equal v2, edge.target
      assert_equal EdgeSet[edge], @digraph.edges

      assert_equal EdgeSet[], v1.in_edges
      assert_equal EdgeSet[edge], v1.out_edges
      assert_equal EdgeSet[], v2.out_edges
      assert_equal EdgeSet[edge], v2.in_edges
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_connect_all
      v1, v2 = @digraph.add_n_vertices(2)
      e1, e2 = @digraph.connect_all([v1, v2], [v2, v1])
      assert_equal VertexSet[v1, v2], @digraph.vertices
      assert_equal EdgeSet[e1, e2], @digraph.edges
      assert_equal VertexSet[v1, v2], e1.extremities
      assert_equal VertexSet[v2, v1], e2.extremities
      assert_equal EdgeSet[e1], v1.out_edges
      assert_equal EdgeSet[e2], v1.in_edges
      assert_equal EdgeSet[e2], v2.out_edges
      assert_equal EdgeSet[e1], v1.out_edges
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_connect_all_with_marks
      v1, v2 = @digraph.add_n_vertices(2)
      e1, e2 = @digraph.connect_all([v1, v2, {:hello => "world"}], [v2, v1, {:hello => "world"}])
      assert_equal VertexSet[v1, v2], @digraph.vertices
      assert_equal EdgeSet[e1, e2], @digraph.edges
      assert_equal VertexSet[v1, v2], e1.extremities
      assert_equal VertexSet[v2, v1], e2.extremities
      assert_equal EdgeSet[e1], v1.out_edges
      assert_equal EdgeSet[e2], v1.in_edges
      assert_equal EdgeSet[e2], v2.out_edges
      assert_equal EdgeSet[e1], v1.out_edges
      assert_equal "world", e1[:hello]
      assert_equal "world", e2[:hello]
      e1[:hello] = "world1"
      assert_equal "world", e2[:hello]
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_remove_edge
      v1, v2 = @digraph.add_n_vertices(2)
      edge = @digraph.connect(v1, v2)
      @digraph.remove_edge(edge)
      assert_equal VertexSet[v1, v2], @digraph.vertices
      assert_equal EdgeSet[], @digraph.edges
      assert_equal EdgeSet[], v1.in_edges
      assert_equal EdgeSet[], v1.out_edges
      assert_equal EdgeSet[], v2.in_edges
      assert_equal EdgeSet[], v2.out_edges

      e1 = @digraph.connect(v1, v2)
      e2 = @digraph.connect(v2, v1)
      assert_equal VertexSet[v1, v2], @digraph.vertices
      assert_equal EdgeSet[e1, e2], @digraph.edges
      assert_equal EdgeSet[e2], v1.in_edges
      assert_equal EdgeSet[e1], v1.out_edges
      assert_equal EdgeSet[e1], v2.in_edges
      assert_equal EdgeSet[e2], v2.out_edges
      @digraph.remove_edge(e1)
      assert_equal VertexSet[v1, v2], @digraph.vertices
      assert_equal EdgeSet[e2], @digraph.edges
      assert_equal EdgeSet[e2], v1.in_edges
      assert_equal EdgeSet[], v1.out_edges
      assert_equal EdgeSet[], v2.in_edges
      assert_equal EdgeSet[e2], v2.out_edges
      assert_equal 0, e2.index
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_remove_edges
      v1, v2, v3 = @digraph.add_n_vertices(3)
      e12 = @digraph.connect(v1, v2)
      e23 = @digraph.connect(v2, v3)
      e32 = @digraph.connect(v3, v2)
      e21 = @digraph.connect(v2, v1)
      @digraph.remove_edges(e12, e23, e32, e21)
      assert_equal EdgeSet[], @digraph.edges
      [v1, v2, v3].each do |v|
        assert_equal EdgeSet[], v.in_edges
        assert_equal EdgeSet[], v.out_edges
      end
      assert_equal [-1], [e12, e23, e32, e21].collect {|e| e.index}.uniq

      e12 = @digraph.connect(v1, v2)
      e23 = @digraph.connect(v2, v3)
      e32 = @digraph.connect(v3, v2)
      e21 = @digraph.connect(v2, v1)
      @digraph.remove_edges(e12, e32)
      assert_equal [-1], [e12, e32].collect {|e| e.index}.uniq
      assert_equal EdgeSet[e23, e21], @digraph.edges
      assert_equal 0, e23.index
      assert_equal 1, e21.index
      assert_equal EdgeSet[e23, e21], v2.out_edges
      assert_equal EdgeSet[e23], v3.in_edges
      assert_equal EdgeSet[e21], v1.in_edges
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_remove_vertex
      v1, v2, v3 = @digraph.add_n_vertices(3)
      e12 = @digraph.connect(v1, v2)
      e23 = @digraph.connect(v2, v3)
      e32 = @digraph.connect(v3, v2)
      e21 = @digraph.connect(v2, v1)
      @digraph.remove_vertex(v1)
      assert_equal -1, v1.index
      assert_equal VertexSet[v2, v3], @digraph.vertices
      assert_equal [0, 1], @digraph.vertices.collect{|v| v.index}
      assert_equal EdgeSet[e23, e32], @digraph.edges
      assert_equal EdgeSet[e23], v2.out_edges
      assert_equal EdgeSet[e32], v2.in_edges
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_reconnect
      v1, v2 = @digraph.add_n_vertices(2)
      edge = @digraph.connect(v1, v2)
      @digraph.reconnect(edge, v2, v1)
      assert_equal VertexSet[v1, v2], @digraph.vertices
      assert_equal EdgeSet[edge], @digraph.edges
      assert_equal v2, edge.source
      assert_equal v1, edge.target
      assert_equal EdgeSet[edge], v1.in_edges
      assert_equal EdgeSet[edge], v2.out_edges
      assert_nothing_raised { @digraph.send(:check_sanity) }
    end

    def test_connect_returns_flatten_set
      sources = @digraph.add_n_vertices(5)
      edges = @digraph.connect(sources, sources)
      assert_equal 25, edges.length
    end

    # def test_remove_vertex_with_block
    #   v1, v2, v3 = @digraph.add_n_vertices(3)
    #   e12 = @digraph.connect(v1, v2)
    #   e23 = @digraph.connect(v2, v3)
    #   e32 = @digraph.connect(v3, v2)
    #   e21 = @digraph.connect(v2, v1)
    #   @digraph.remove_vertex(v3) do |g,ine,oute|
    #     g.reconnect(ine, nil, v1)
    #     g.reconnect(oute, v1, nil)
    #     assert (v3.in_edges+v3.out_edges).empty?
    #   end
    #   assert_equal [e12, e23, e32, e21], @digraph.edges
    #   assert_equal [v1, v2], e12.extremities
    #   assert_equal [v2, v1], e23.extremities
    #   assert_equal [v1, v2], e32.extremities
    #   assert_equal [v2, v1], e21.extremities
    #   assert_equal [e21, e23], v1.in_edges
    #   assert_equal [e12, e32], v1.out_edges
    #   assert_equal [e12, e32], v2.in_edges
    #   assert_equal [e23, e21], v2.out_edges
    #   assert_nothing_raised { @digraph.send(:check_sanity) }
    # end
    #
    # def test_remove_vertex_with_block_using_edge_shortcuts
    #   v1, v2, v3 = @digraph.add_n_vertices(3)
    #   e12 = @digraph.connect(v1, v2)
    #   e23 = @digraph.connect(v2, v3)
    #   e32 = @digraph.connect(v3, v2)
    #   e21 = @digraph.connect(v2, v1)
    #   @digraph.remove_vertex(v3) do |g,ine,oute|
    #     ine.each do |e| e.target = v1 end
    #     oute.each do |e| e.source = v1 end
    #     assert (v3.in_edges+v3.out_edges).empty?
    #   end
    #   assert_equal [e12, e23, e32, e21], @digraph.edges
    #   assert_equal [v1, v2], e12.extremities
    #   assert_equal [v2, v1], e23.extremities
    #   assert_equal [v1, v2], e32.extremities
    #   assert_equal [v2, v1], e21.extremities
    #   assert_equal [e21, e23], v1.in_edges
    #   assert_equal [e12, e32], v1.out_edges
    #   assert_equal [e12, e32], v2.in_edges
    #   assert_equal [e23, e21], v2.out_edges
    #   assert_nothing_raised { @digraph.send(:check_sanity) }
    # end

  end
end
