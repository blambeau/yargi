require 'yargi/digraph_vertex'
require 'yargi/digraph_edge'

module Yargi

  #
  # Directed graph implementation.
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
      pred = Yargi::Predicate.to_predicate(filter, &block)
      return @vertices.select{|v| pred===v}
    end
    
    # Calls block on each graph vertex. If _filter_ is not nil?, only vertices
    # for which the predicate evalutes to true are iterated.
    def each_vertex(filter=nil, &block)
      return unless block_given?
      if filter.nil?
        @vertices.each &block
      else
        vertices(filter).each &block
      end
    end
    
    # Adds a vertex
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
    
    # Removes a vertex and all incoming and outgoing edges.
    def remove_vertex(vertex)
      # remove connected edges
      remove_edges(vertex.in_edges + vertex.out_edges)
      
      # now, remove the vertex itself
      index = vertex.index
      index.upto(@vertices.length-1) {|i| @vertices[i].index -= 1}
      @vertices.delete_at(index)
      
      # deconnect the vertex
      vertex.index=-1
      self
    end
  
    ### Edge management ##################################################
    
    # Returns all graph edges for which the 'filter and block' predicate
    # evaluates to true (see Yargi::Predicate).
    def edges(filter=nil, &block)
      pred = Yargi::Predicate.to_predicate(filter, &block)
      return @edges.select{|e| pred===e}
    end
    
    # Calls block on each graph edge
    def each_edge(filter=nil, &block)
      return unless block_given?
      if filter.nil?
        @edges.each &block
      else
        edges(filter).each &block
      end
    end
    
    # Connects source to target state(s)
    def add_edge(source, target, *args)
      if looks_a_set?(source)
        EdgeSet.new(source.collect {|src| connect(src, target, *args)}).flatten
      elsif looks_a_set?(target)
        EdgeSet.new(target.collect {|trg| connect(source, trg, *args)}).flatten
      else
        raise ArgumentError, "Source may not be nil" unless source
        raise ArgumentError, "Target may not be nil" unless target
        edge = Digraph::Edge.new(self, @edges.length, source, target)
        apply_arg_conventions(edge, args)
        source.add_out_edge(edge)
        target.add_in_edge(edge)
        @edges << edge
        edge
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
    
    # Removes an edge from the graph
    def remove_edge(edge)
      index = edge.index
      index.upto(@edges.length-1) {|i| @edges[i].index -= 1}
      edge.source.remove_out_edge(edge)
      edge.target.remove_in_edge(edge)
      @edges.delete_at(index)
      
      # deconnect the edge
      edge.index = -1
      
      self
    end
    
    # Removes all edges given as argument
    def remove_edges(*edges)
      edges = edges[0] if edges.length==1 and looks_a_set?(edges[0])
      edges.sort{|e1,e2| e2.index <=> e1.index}.each do |edge|
        # allowed because edges are sorted in reverse order of index
        edge.source.remove_out_edge(edge)
        edge.target.remove_in_edge(edge)
        @edges.delete_at(edge.index)
        edge.index = -1
      end
      @edges.each_with_index {|edge,i| edge.index=i}
      self
    end
    
    # Reconnects some edge
    def reconnect(edge, source, target)
      if looks_a_set?(edge)
        edge.each {|e| reconnect(e,source,target)}
        edges
      else
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
    
    # Converts a hash to dot attributes
    def to_dot_attributes(hash)
      # TODO: fix uncompatible key names
      # TODO: some values must be encoded (backquoting and the like)
      buffer = ""
      hash.each_pair do |k,v|
        buffer << "#{k}=\"#{v}\""
      end
      buffer
    end
    
    ### Argument conventions #############################################
    protected
    
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