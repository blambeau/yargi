require 'yargi'

Bench.runner do |b|
  b.variation_point :version, Yargi::VERSION
  b.variation_point :ruby, Bench.which_ruby
  b.range_over([100,200,300,400,500], :size) do |size|
    b.range_over(1..5, :i) do
      bench_case = Yargi::Digraph.random(size, 4*size)
      b.report(:vertex_count => bench_case.vertex_count,
               :test => :depth) do
        Yargi::Decorate::DEPTH.execute(bench_case)
      end
    end
  end
end
