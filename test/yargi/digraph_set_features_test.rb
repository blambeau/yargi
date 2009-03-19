require 'test/unit'
require 'yargi'

module Yargi
  
  # Tests all set-based features on graphs
  class DigraphSetFeaturesTest < Test::Unit::TestCase
    
    module Source; end
    module Sink; end
    module Additional; end
    
    # Installs the souce-sink graph example under @graph
    def setup
      @graph = Yargi::Digraph.new
      sources = @graph.add_n_vertices(10, Source)
      sinks = @graph.add_n_vertices(10, Sink)
      @graph.connect(sources, sinks)
    end
    
    def test_tag
      @graph.vertices{|v| Source===v}.tag(Additional)
      @graph.vertices.each {|v| assert_equal((Source===v), (Additional===v))}
      assert @graph.vertices{|v| Source===v}.all?{|v|Additional===v}
      assert @graph.vertices{|v| Sink===v}.all?{|v|not(Additional===v)}
    end
    
    def test_set_and_get_mark
      @graph.vertices{|v| Source===v}.set_mark(:kind, :source)
      @graph.vertices{|v| Sink===v}.set_mark(:kind, :sink)
      @graph.vertices.each do |v|
        if Source===v
          assert_equal :source, v.get_mark(:kind)
        else
          assert_equal :sink, v.get_mark(:kind)
        end
      end
    end
    
    def test_set_and_get_mark_with_hash_API
      @graph.vertices{|v| Source===v}[:kind] = :source
      @graph.vertices{|v| Sink===v}[:kind] = :sink
      @graph.vertices.each do |v|
        if Source===v
          assert_equal :source, v[:kind]
        else
          assert_equal :sink, v[:kind]
        end
      end
    end
    
    def test_set_and_get_mark_with_object_API
      @graph.vertices{|v| Source===v}[:kind] = :source
      @graph.vertices{|v| Sink===v}[:kind] = :sink
      @graph.vertices.each do |v|
        if Source===v
          assert_equal :source, v.kind
        else
          assert_equal :sink, v.kind
        end
      end
    end
    
    def test_add_marks
      @graph.vertices{|v| Source===v}.add_marks(:kind => :source, :priority => 1.0)
      @graph.vertices.each do |v|
        if Source===v
          assert_equal :source, v.kind
          assert_equal 1.0, v.priority
        end      
      end
    end
    
  end # class DigraphSetFeaturesSet
  
end