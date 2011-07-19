bench -Ilib run bench/bench_decorate.rb > bench/bench_decorate.rash
bench plot bench/bench_decorate.rash -x vertex_count -y real -g version -s ruby --gnuplot=gif | gnuplot > bench/bench_decorate.gif