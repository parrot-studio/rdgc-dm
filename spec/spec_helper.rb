$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rdgc-dm'
require 'spec'
require 'spec/autorun'

include RDGC

Spec::Runner.configure do |config|
  
end
