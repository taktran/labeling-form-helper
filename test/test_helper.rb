%w( rubygems active_support action_controller action_view mocha stubba test/unit ).each { |x| require x }
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
