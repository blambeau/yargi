# 0.2.0 / FIX ME

* Enhancements

  * Digraph.new now yields self if a block is given. This allows building a 
    graph more smoothly:
    
        graph = Digraph.new{|d|
          d.add_n_vertices(5)
          ...
        }
        
  * An integer is now automatically recognized as a selection predicate. This 
    means that the following will work:
    
        # [... previous example continued ...]
        graph.vertices(2) # => returns the 2-th vertex (0, 1, **2**)
        
        # connection can be made simply as
        graph.connect(1, 2)

  * Added Digraph#ith_vertex and Digraph#ith_edge 

* Internals & Devel

  * The project structure is now handled with Noe.

# 0.1.2

* Enhancements

  * Markable.add_marks also accepts a block to mimic add_n_vertices and 
    ElementSet.add_marks
  * EdgeSet forwards source= and target= to its elements, allowing bulk 
    reconnection
  * Digraph.to_dot_attributes made much more smart on typical array values

* Bug fixes

  * Markable.has_key? is used to avoid predicate side-effects on v[:mark] when 
    the mark is false
    
# 0.1.1

  * Bug fix in dot generation
  * Examples started and documentation improved
  * Web site index generation using wlang

# 0.1.0

  * Birthday!