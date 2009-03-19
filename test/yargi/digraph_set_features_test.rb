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
      sources = @graph.add_n_vertices(5, Source)
      sinks = @graph.add_n_vertices(5, Sink)
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
    
    def test_add_marks_with_block
      @graph.vertices{|v| Source===v}.add_marks do |v|
        v.set_mark(:test, true)
        {:kind => :source, :priority => 1.0}
      end
      @graph.vertices{|v| Source===v}.all? do |v|
        assert v.test==true 
        assert_equal :source, v.kind
        assert_equal 1.0, v.priority
      end
    end
    
    def test_add_marks_with_both
      @graph.vertices{|v| Source===v}.add_marks(:test2 => false) do |v|
        v.set_mark(:test, true)
        {:kind => :source, :priority => 1.0}
      end
      @graph.vertices{|v| Source===v}.all? do |v|
        assert v.test2==false
        assert v.test==true
        assert_equal :source, v.kind
        assert_equal 1.0, v.priority
      end
    end
    
    def test_to_dot
      @graph.vertices{|v|Source===v}.add_marks(:label => '', :shape => 'diamond', :fixedsize => true, :width => 0.5)
      @graph.vertices{|v|Sink===v}.add_marks(:label => '', :shape => 'doublecircle', :fixedsize => true, :width => 0.5)
      @graph.edges.add_marks do |e|
        {:label => "from #{e.source.index} to #{e.target.index}"}
      end
      dir = File.expand_path(File.dirname(__FILE__))
      dotfile = File.join(dir,"source-sink.dot")
      gitfile = File.join(dir,"source-sink.gif")
      File.open(dotfile, 'w') {|f| f << @graph.to_dot}
      begin
        `dot -Tgif -o #{gitfile} #{dotfile}`
      rescue => ex
        $STDERR << "dot test failed, probably not installed\n#{ex.message}"
      end
    end
    
    
    
  end # class DigraphSetFeaturesSet
  
end