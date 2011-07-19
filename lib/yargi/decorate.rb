module Yargi
  class Decorate
    attr_accessor :key
    attr_accessor :bottom
    attr_accessor :d0
    attr_accessor :suppremum
    attr_accessor :propagate
    
    def initialize
      yield(self) if block_given?
    end

    def execute(digraph, initials)
      # all to bottom except initial states
      digraph.each_vertex{|s| s[key] = bottom}
      initials.each{|s| s[key] = d0}
        
      # main loop
      to_explore = initials
      until to_explore.empty?
        source = to_explore.pop
        source.out_edges.each do |edge|
          target = edge.target
          p_decor = propagate.call(source[key], edge)
          p_decor = suppremum.call(target[key], p_decor)
          unless p_decor == target[key]
            target[key] = p_decor
            to_explore << target unless to_explore.include?(target)
          end
        end
      end
    end
    
    DEPTH = Decorate.new{|d|
      d.key    = :depth
      d.bottom = 1.0/0
      d.d0     = 0
      d.suppremum = lambda{|d1,d2| d1 < d2 ? d1 : d2}
      d.propagate = lambda{|d,e| d+1} 
    }
  
  end # class Decorate
end # module Yargi