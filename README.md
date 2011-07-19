# Yargi

Yet Another Ruby Graph Library 

## Links

* http://rubydoc.info/github/blambeau/yargi/master/frames
* http://github.com/blambeau/yargi
* http://rubygems.org/gems/yargi

## Description

Yargi provides a powerful **mutable** digraph implementation. It has been 
designed to allow full mutability the easy way. A quick tour below.

## Quick tour

### Digraph, Vertex and Edge

Unlike {http://rubyforge.org/projects/rgl/ RGL}, Yargi implements graph 
components through concrete classes, not modules (that is, in a 
standard-but-closed way). See Digraph, Digraph::Vertex and Digraph::Edge 
respectively.

### Markable pattern

Graphs, vertices and edges are markable through a Hash-like API: users can 
install their own key/value pairs on each graph element. When keys are Symbol
objects, accessors are automatically generated to provide a friendly 
object-oriented API (this feature must be used with care, for obvious reasons).

    graph = Yargi::Digraph.new
    v1 = graph.add_vertex(:kind => "simple vertex")
    puts v1.kind    
    # => "simple vertex"

### Typed elements

Graph elements (vertices and edges) can be tagged with your own modules (at 
creation, or later). This is the standard Yargi way to apply a 'select-and-do' 
feature described below:

    # These are node types
    module Diamond; end
    module Circle; end
    
    # Let build a graph with 5 diamonds
    graph = Yargi::Digraph.new
    graph.add_n_vertices(5, Diamond) do |v,i|
      v[:color] = (i%2==0 ? 'red' : 'blue')
    end

    # Let add 5 circles
    graph.add_n_vertices(5, Circle)

    # connect all diamonds to all circles
    graph.connect(Diamond, Circle)  

### Selection mechanism 

Yargi helps you finding the nodes and edges you are looking for through a 
declarative selection mechanism: almost all methods that return a set of 
vertices or edges (Vertex.out_edges, for example) accept a predicate argument 
to filter the result, module names being most-used shortcuts. 
See Yargi::Predicate for details.

    # [... previous example continued ...]
    graph.vertices(Diamond)                       # selects all diamonds
    graph.vertices(Diamond){|v| v.color=='blue'}  # selects blue diamonds only
    
    # Proc variant, find sink states
    sink = Yargi.predicate {|v| v.out_edges.empty?}
    graph.vertices(sink & Circle)                 # select all Circle sink states (no one)
    
    # Or selection
    is_blue = Yargi.predicate {|v| Diamond===v and v.color=='blue'}
    graph.vertices(is_blue|Circle)                # select blue diamonds and circles

### VertexSet and EdgeSet 

The selection mechanism always returns arrays ... being instances of 
Yargi::VertexSet and Yargi::EdgeSet. These classes help you walking your graph 
easily:

    # [... previous example continued ...]
    circles = graph.vertices(Diamond).adjacent
    puts graph.vertices(Circle)==circles        
    # => true
    
### Select-and-do

Many graph methods accept sets of vertices and edges as well as selection queries
to work. Instead of connecting one source to one target at a time by passing the 
vertices, describe what you want and Yardi does it. Add, connect, remove, mark,
reconnect many vertices/edges with a single method call:

    graph.vertices(Diamond).add_marks(:label => '', :shape => 'diamond')
    graph.vertices(Circle).add_marks(:label => '', :shape => 'circle')
    puts graph.to_dot
    graph.remove_vertices(Circle) # remove all circles

### Mutable graphs 

Graphs here are mutable, mutable and mutable and this is the reason why Yargi
exists. It comes from a project where manipulating graphs by reconnecting edges,
removing vertices is the norm, not the exception.

### Complexity don't care

The digraph implementation uses an incident list data structure. This graph
library has not been designed with efficiency in mind so that complexities 
are not documented nor guaranteed. That is not to say that improvements are
not welcome, of course.

## Distribution & Credits

_Yargi_ is freely available (under a MIT licence) as a 'yargi' gem on 
{http://rubygems.org/gems/yargi rubygems.org}. Use 'gem install yargi' to 
install it. The sources are on {http://github.com/blambeau/yargi github}, which
is also the place where bugs and issues can be reported.

This work is supported by the {http://www.uclouvain.be/en-ingi.html department 
of computer science} of the {http://www.uclouvain.be/en-index.html University of 
Louvain} (EPL/INGI, Universite Catholique de Louvain, UCL, Louvain-la-Neuve, 
Belgium).

This work was also partially supported by the Regional Government of Wallonia 
(GISELE project, RW Conv. 616425).
