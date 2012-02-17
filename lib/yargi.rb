require 'yargi/version'
require 'yargi/loader'
require 'yargi/predicate'
module Yargi

  # When _what_ is not nil, converts it to a predicate (typically a module).
  # Otherwise, a block is expected, which is converted to a LambdaPredicate.
  # Otherwise, return ALL.
  def self.predicate(what=nil, &block)
    Predicate.to_predicate(what, &block)
  end

  # Predicates that always return true
  ALL = Yargi::Predicate.to_predicate(true)

  # Predicates that always return false
  NONE = Yargi::Predicate.to_predicate(false)

end
require 'yargi/markable'
require 'yargi/digraph'
require 'yargi/digraph_vertex'
require 'yargi/digraph_edge'
require 'yargi/element_set'
require 'yargi/vertex_set'
require 'yargi/edge_set'
require 'yargi/decorate'
require 'yargi/random'
