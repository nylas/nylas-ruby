$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'nylas'
require 'faker'

require 'method_source'
def demonstrate(&block)
  block.source.display
  result = block.call
  puts "# => #{result}"
  result
end
