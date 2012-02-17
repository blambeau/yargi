$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..', 'lib'))
require 'yargi'
require 'test/unit'
test_files = Dir[File.join(File.dirname(__FILE__), '**/*_test.rb')]
test_files.each { |file|
  require(file)
}

