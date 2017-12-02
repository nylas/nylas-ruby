$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'nylas'

require 'method_source'
def demonstrate(&block)
  block.source.display
  puts "# => #{block.call}"
end
