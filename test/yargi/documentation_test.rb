require 'test/unit'
require 'yargi'

module Yargi

  # Here to check that what's in the documentation is correct
  class DocumentationTest < Test::Unit::TestCase

    module Source; end
    module Sink; end

    def test_README_example
      # create a directed graph
      digraph = Yargi::Digraph.new

      # create 10 source and 5 sink vertices, tag them with user modules
      sources = digraph.add_n_vertices(5, Source)
      assert VertexSet===sources

      # connect source to sink states
      edges = digraph.connect(sources, sources)
      assert EdgeSet===edges

      # put some dot attributes
      sources.add_marks(:shape => 'circle', :label => '')
      edges.add_marks do |e|
        {:label => "From #{e.source.index} to #{e.target.index}"}
      end

      # and print it
      dir = File.expand_path(File.dirname(__FILE__))
      dotfile = File.join(dir,"README-example.dot")
      gitfile = File.join(dir,"README-example.gif")
      File.open(dotfile, 'w') {|f| f << digraph.to_dot}
      begin
        `dot -Tgif -o #{gitfile} #{dotfile}`
      rescue => ex
        $STDERR << "dot test failed, probably not installed\n#{ex.message}"
      end
    end

  end # class DocumentationTest

end
