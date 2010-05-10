$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack-rescue'
require 'spec'
require 'spec/autorun'
require 'wrapt'

Spec::Runner.configure do |config|

end

class MyNotFoundException < StandardError; end

SUCCESS_APP = lambda{|e| Rack::Response.new("ok").finish }

FAIL_APP    = lambda do |e|
  if $fail_with
    raise $fail_with
  else
    raise RuntimeError
  end
end
