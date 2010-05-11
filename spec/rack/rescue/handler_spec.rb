require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Rack::Rescue::Handler do
  subject { Rack::Rescue::Handler }

  before(:all) do
    root = File.join(File.expand_path(::File.dirname(__FILE__)), "fixtures")
    subject.roots << root
    subject.push_paths(:error_templates, "alternate_errors", "**/*")
  end

  it "should have a default format of :text" do
    subject.default_format.should == :text
  end

  it "should allow me to set a default format" do
    df = subject.default_format
    subject.default_format = :html
    subject.default_format.should == :html
    subject.default_format = df
  end

  it "should return true when asked if a template is present and it is" do
    subject.template?(:not_found, :format => :text).should be_true
  end

  it "should return false when asked if a template is present and it's not" do
    subject.template?(:never_was_here).should be_false
  end

  it "should fetch a given template" do
    subject.template(:not_found).should be_a_kind_of(Pancake::Mixins::Render::Template)
  end

  it "should set the template format via the format option" do
    subject.template(:not_found, :format => :xml).should_not be_nil
  end

  describe "render_error" do
    class RackRescueCustom1 < StandardError; end
    class RackRescueCustom2 < StandardError; end
    class RackRescueCustom3 < StandardError; end

    before do
      @handler = Rack::Rescue::Handler.new(RackRescueCustom1, :template => "custom_exception", :status => 412)
      begin
        raise RackRescueCustom1, "Custom Error Message"
      rescue => e
        @exception = e
      end
    end

    it "should render the template that the exception is associated with" do
      result = @handler.render_error(@exception)
      result.should include("Custom Exception Template")
    end

    it "should fallback to the normal error template if the specified template cannot be found" do
      @handler.default_template = "not_a_real_template"
      result = @handler.render_error(@exception)
      result.should include("Error")
    end

    it "should allow me to inherit from error and overwrite the error_header" do
      @handler.default_template = "inherit_from_error_header"
      result = @handler.render_error(@exception)
      result.should include("Overwritten Error Header")
    end

    it "should allow me to inherit from error and overwrite the error_message" do
      @handler.default_template = "inherit_from_error_message"
      result = @handler.render_error(@exception)
      result.should include("Overwritten Error Message")
    end

    it "should allow me to inherit from error and overwrite the error_backtrace" do
      @handler.default_template = "inherit_from_error_backtrace"
      result = @handler.render_error(@exception)
      result.should include("Overwritten Error Backtrace")
    end

    it "should allow me to overwrite the default format for the handler" do
      handler = Rack::Rescue::Handler.new(RackRescueCustom1, :template => "custom_exception", :status => 412, :format => :html)
      result = handler.render_error(@exception)
      result.should include("<h1>412 Error")
    end

    it "should render the exception using the foo_env error template" do
      begin
        orig_env = ENV['RACK_ENV']
        ENV['RACK_ENV'] = "foo_env"
        handler = Rack::Rescue::Handler.new(RackRescueCustom1, :template => "alternate_exceptions", :format => :html)
        result = handler.render_error(@exception, :format => :html)
        result.should include("In alternate_exceptions.foo_env.html.erb")
      ensure
        ENV['RACK_ENV'] = orig_env
      end
    end

    it "should render the exception using the standard error template" do
      begin
        orig_env = ENV['RACK_ENV']
        ENV['RACK_ENV'] = nil
        handler = Rack::Rescue::Handler.new(RackRescueCustom1, :template => "alternate_exceptions", :format => :html)
        result = handler.render_error(@exception)
        result.should include("In alternate_exceptions.html.erb")
      ensure
        ENV['RACK_ENV'] = orig_env
      end
    end
  end
end
