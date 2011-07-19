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
    
* Internals & Devel

  * The project structure is now handled with Noe.

# 0.1.1

  * Bug fix in dot generation
  * Examples started and documentation improved
  * Web site index generation using wlang

# 0.1.0

  * Birthday!