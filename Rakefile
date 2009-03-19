require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"
require "rubygems"

dir     = File.dirname(__FILE__)
lib     = File.join(dir, "lib", "yargi.rb")
version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d)\1/, 2]

task :default => [:test]

desc "Lauches all tests"
Rake::TestTask.new do |test|
  test.libs       << [ "lib", "test" ]
  test.test_files = ['test/test_all.rb']
  test.verbose    =  true
end

desc "Generates rdoc documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README", "LICENCE", "lib/" )
  rdoc.main     = "README"
  rdoc.rdoc_dir = "doc/api"
  rdoc.title    = "Yargi v.#{version}"
end

gemspec = Gem::Specification.new do |s|
  s.name = 'yargi'
  s.version = version
  s.summary = "Yet Another Ruby Graph Implementation"
  s.description = %{Mutable graphs made easy.}
  s.files = Dir['lib/**/*'] + Dir['test/**/*'] 
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENCE"]
  s.rdoc_options << '--title' << 'Yargi - Yet Another Ruby Graph Implementation' <<
                    '--main' << 'README' <<
                    '--line-numbers'  
  s.author = "Bernard Lambeau"
  s.email = "blambeau@gmail.com"
  s.homepage = "https://code.chefbe.net/"
end
Rake::GemPackageTask.new(gemspec) do |pkg|
	pkg.need_tar = true
end
