dependencies = %w( rubygems active_support action_controller action_view mocha stubba )

begin
  dependencies.each { |x| require x }
rescue LoadError
  puts "you are missing one of the dependencies: #{dependencies * ', '}"
end

require 'test/unit'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')