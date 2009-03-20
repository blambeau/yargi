require 'yargi/digraph_vertex'
require 'yargi/digraph_edge'

module Yargi

  #
  # Directed graph implementation.
  #
  # * All selection methods (vertices, each_vertex, edges, each_edge) implement the 
  #   predicate-selection mechanism (they accept a predicate filter as well as a 
  #   predicate block, with a AND semantics when used conjointly).
  # * Removal methods (remove_vertex, remove_vertices, remove_edge, remove_edges)
  #   accept varying arguments that are automatically converted to set of vertices 
  #   or edges. Recognized arguments are Vertex and Edge instances, VertexSet and 
  #   EdgeSet instances, Array instances, and predicates. When multiple arguments
  #   are used conjointly, a OR-semantics is applied.
  #
  #   Example:
  #     graph.remove_vertices(Circle, Diamond)               # removes all vertices tagged as Circle OR Diamond
  #     graph.remove_vertices(Yargi::ALL & Circle & Diamond) # remove vertices that are both Circle and Diamond
  #
  class Digraph
    include Yargi::Markable
  
    # Creates an empty graph instance
    def initialize
      @vertices = VertexSet[]
      @edges = EdgeSet[]
      @marks = {}
    end
    
    ### Vertex management ################################################
    
    # Returns all graph vertices for which the 'filter and block' predicate
    # evaluates to true (see Yargi::Predicate).
    def vertices(filter=nil, &block)
      @vertices.filter(filter, &block)
    end
    
    # Calls block on each graph vertex for with the 'filter and block' predicate
    # evaluates to true.
    def each_vertex(filter=nil, &block)
      return unless block_given?
      if filter.nil?
        @vertices.each &block
      else
        vertices(filter).each &block
      end
    end
    
    # Adds a vertex. _args_ can be module instances or hashes, 
    # which are all installed on the vertex _v_ using  <tt>v.tag</tt> 
    # and <tt>v.add_marks</tt>, respectively. 
    def add_vertex(*args)
      vertex = Digraph::Vertex.new(self, @vertices.length)
      apply_arg_conventions(vertex, args)
      @vertices << vertex
      vertex
    end
    
    # Creates n vertices. _args_ can be module instances or hashes, 
    # which are all installed on vertices _v_ using  <tt>v.tag</tt> 
    # and <tt>v.add_marks</tt>, respectively. If a block is given, 
    # it is called after each vertex creation. The vertex is passed
    # as first argument and the iteration index (from 0 to n-1) as
    # second one.
    def add_n_vertices(n, *args)
      vertices = []
      n.times do |i|
        vertex = add_vertex(*args)
        vertices << vertex
        yield vertex, i if block_given?
      end
      VertexSet.new(vertices)
    end
    
    # Removes all vertices returned by evaluating the _vertices_ selection 
    # expression.
    def remove_vertices(*vertices)
      vertices = to_vertices(*vertices).sort{|v1,v2| v2<=>v1}
      vertices.each do |vertex|
        remove_edges(vertex.in_edges+vertex.out_edges)
        @vertices.delete_at(vertex.index)
        vertex.index=-1
      end
      @vertices.each_with_index {|v,i| v.index=i}
      self
    end
    alias :remove_vertex :remove_vertices 
    
    ### Edge management ##################################################
    
    # Returns all graph edges for which the 'filter and block' predicate
    # evaluates to true (see Yargi::Predicate).
    def edges(filter=nil, &block)
      @edges.filter(filter, &block)
    end
    
    # Calls block on each graph edge for with the 'filter and block' predicate
    # evaluates to true.
    def each_edge(filter=nil, &block)
      return unless block_given?
      if filter.nil?
        @edges.each &block
      else
        edges(filter).each &block
      end
    end
    
    # Connects source to target state(s). _source_ and _target_ may be any 
    # selection expression that can lead to vertex sets. _args_ can be module 
    # instances or hashes,  which are all installed on edges _e_ using 
    # <tt>e.tag</tt> and <tt>e.add_marks</tt>, respectively.
    def add_edge(source, target, *args)
      if Vertex===source and Vertex===target
        edge = Digraph::Edge.new(self, @edges.length, source, target)
        apply_arg_conventions(edge, args)
        source.add_out_edge(edge)
        target.add_in_edge(edge)
        @edges << edge
        edge
      else
        sources, targets = to_vertices(source), to_vertices(target)
        created = EdgeSet[]
        sources.each do |src|
          targets.each do |trg|
            created << add_edge(src, trg, *args)
          end
        end
        created
      end
    end
    alias :connect :add_edge
    
    # Adds many edges at once
    def add_edges(*extremities)
      extremities.collect do |extr|
        add_edge(extr[0], extr[1], *extr[2..-1])
      end
    end
    alias :connect_all :add_edges
    
    # Removes all edges returned by evaluating the _edges_ selection 
    # expression.
    def remove_edges(*edges)
      edges = to_edges(edges).sort{|e1,e2| e2<=>e1}
      edges.each do |edge|
        edge.source.remove_out_edge(edge)
        edge.target.remove_in_edge(edge)
        @edges.delete_at(edge.index)
        edge.index = -1
      end
      @edges.each_with_index {|edge,i| edge.index=i}
      self
    end
    alias :remove_edge :remove_edges
    
    # Reconnects some edge(s). _source_ and _target_ are expected to be
    # Vertex instances, or nil. _edges_ may be any selection expression 
    # that can be converted to an edge set. This method reconnects all
    # edges to the specified source and target vertices (at least one is
    # expected not to be nil).
    def reconnect(edges, source, target)
      raise ArgumentError, "Vertices expected as source and target"\
        unless (source.nil? or Vertex===source) and (target.nil? or Vertex===target)
      to_edges(edges).each do |edge|
        if source
          edge.source.remove_out_edge(edge)
          source.add_out_edge(edge)
        end 
        if target
          edge.target.remove_in_edge(edge)
          target.add_in_edge(edge)
        end
        edge.reconnect(source, target)
        edge
      end
    end

    ### Standard exports #################################################
    
    # Encodes this graph for dot graphviz
    def to_dot(buffer='')
      buffer << "digraph G {\n"
      buffer << "  graph[#{to_dot_attributes(self.to_h(true))}]\n"
      each_vertex do |v|
        buffer << "  V#{v.index} [#{to_dot_attributes(v.to_h(true))}]\n"
      end
      each_edge do |e|
        buffer << "  V#{e.source.index} -> V#{e.target.index} [#{to_dot_attributes(e.to_h(true))}]\n"
      end
      buffer << "}\n"
    end
    
    ### Argument conventions #############################################
    protected
    
    # Converts a hash to dot attributes
    def to_dot_attributes(hash)
      # TODO: fix uncompatible key names
      # TODO: some values must be encoded (backquoting and the like)
      buffer = ""
      hash.each_pair do |k,v|
        buffer << " " unless buffer.empty?
        buffer << "#{k}=\"#{v}\""
      end
      buffer
    end
    
    # Checks if _arg_ looks like an element set
    def looks_a_set?(arg)
      Array===arg or ElementSet===arg
    end
    
    # Checks graph sanity
    def check_sanity
      @vertices.each_with_index do |v,i| 
        raise "Removed vertex in vertex list" unless v.index==i
        v.in_edges.each do |ine|
          raise "Removed edge in vertex incoming edges" if ine.index<0
          raise "Vertex and edge don't agree on target" unless ine.target==v 
        end
        v.out_edges.each do |oute|
          raise "Removed edge in vertex outgoing edges" if oute.index<0
          raise "Vertex and edge don't agree on source" unless oute.source==v 
        end
      end
      @edges.each_with_index do |e,i| 
        raise "Removed edge in edge list" unless e.index==i
        raise "Edge in-connected to a removed vertex" if e.source.index<0
        raise "Edge out-connected to a removed vertex" if e.target.index<0
      end
    end
    
    # Applies argument conventions about selection of vertices
    def to_vertices(*args)
      selected = args.collect do |arg|
        case arg
          when VertexSet
            arg
          when Array
            arg.collect{|v| to_vertices(v)}.flatten.uniq
          when Digraph::Vertex
            [arg]
          else
            pred = Predicate.to_predicate(arg)
            vertices(pred)
        end
      end.flatten.uniq
      VertexSet.new(selected)
    end
  
    # Applies argument conventions about selection of edges
    def to_edges(*args)
      selected = args.collect do |arg|
        case arg
          when EdgeSet
            arg
          when Array
            arg.collect{|v| to_edges(v)}.flatten.uniq
          when Digraph::Edge
            [arg]
          else
            pred = Predicate.to_predicate(arg)
            edges(pred)
        end
      end.flatten.uniq
      EdgeSet.new(selected)
    end
  
    # Applies argument conventions on _element_
    def apply_arg_conventions(element, args)
      args.each do |arg|
        case arg
          when Module
            element.tag(arg)
          when Hash
            element.add_marks(arg)
          else
            raise ArgumentError, "Unable to apply argument conventions on #{arg.inspect}", caller
        end
      end
      element
    end
    
  end # class Digraph
  
end