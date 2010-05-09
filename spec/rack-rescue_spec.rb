require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RackRescue" do
  class RRUnknownException < RuntimeError; end

  def safe_endpoint(msg = "OK")
    lambda{|e| Rack::Response.new(msg)}
  end

  def raise_endpoint(exception, msg)
    lambda{|e| raise exception, msg }
  end

  def build_stack(endpoint = safe_endpoint)
    Rack::Builder.new do
      use Rack::Rescue
      run endpoint
    end
  end

  before do
    @env = Rack::MockRequest.env_for("/")
  end

  it "should do nothing if there is no downstream exception" do
    result = build_stack.call(@env)
    result.body.map.join.should == "OK"
  end

  it "should re-raise the exception if it is not registered" do
    bad_app = raise_endpoint(RRUnknownException, "Unknown Brew")
    stack = build_stack(bad_app)
    lambda do
      stack.call(@env)
    end.should raise_error(RRUnknownException, "Unknown Brew")
  end

  describe "A known exception" do
    it "should render the template for the error" do
      bad_app = raise_endpoint(Pancake::Errors::NotFound, "Action Not Found")
      stack = build_stack(bad_app)
      r = stack.call(@env)

      body = r[2].body.map.join
      body.should include("Pancake::Errors::NotFound")
    end

    it "should set the correct status code" do
      bad_app = raise_endpoint(Pancake::Errors::NotFound, "Action Not Found")
      stack = build_stack(bad_app)
      r = stack.call(@env)

      status = r[0]
      status.should == 404
      body = r[2].body.map.join
      body.should include("Action Not Found")
    end
  end
end
