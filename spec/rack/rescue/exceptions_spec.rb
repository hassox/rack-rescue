require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Rack::Rescue::Exceptions do
  subject { Rack::Rescue::Exceptions.new(false) }

  before do
    subject.add("MyNotFoundException")
  end

  it "should allow me to access the exception" do
    subject["MyNotFoundException"].should be_an_instance_of(Rack::Rescue::Handler)
  end

  it "should provide me with a hash of all handlers" do
    handler = subject.exception_handlers["MyNotFoundException"]
    subject.exception_handlers.should == {"MyNotFoundException" => handler}
  end

  it "should allow me to remove handling of an exception" do
    subject.delete("MyNotFoundException")
    subject["MyNotFoundHandler"].should be_nil
  end

  it "should set the status of the exception to 500 by default" do
    subject["MyNotFoundException"].status.should == 500
  end

  it "should allow me to change the status of an exception" do
    handler = subject["MyNotFoundException"]
    handler.status = 404
    handler.status.should == 404
  end

  describe "accessing handlers" do
    before do
      @handler = subject["MyNotFoundException"]
    end

    it "should allow me to access the exception with the constnat" do
      subject[MyNotFoundException].should == @handler
    end

    it "should allow me to access the exception with an instance" do
      subject[MyNotFoundException.new].should == @handler
    end
  end

  it "should add to the default list" do
    e = Rack::Rescue::Exceptions
    lambda do
      e.add_defaults("MyException", :status => 400)
    end.should change(e::DEFAULT_HANDLERS, :size).by(1)
  end

  it "should add to the default list with a string" do
    e = Rack::Rescue::Exceptions
    e.add_defaults("MyException", "SomethingElse", "Another")
    lambda do
      e.remove_defaults("SomethingElse", "Another")
    end.should change(Rack::Rescue::Exceptions::DEFAULT_HANDLERS, :size).by(-2)
  end

  it "should add to the default list with a string" do
    e = Rack::Rescue::Exceptions
    e.add_defaults("Foo::MyException", "Foo::SomethingElse", "Another")
    lambda do
      e.remove_defaults(/^Foo/)
    end.should change(Rack::Rescue::Exceptions::DEFAULT_HANDLERS, :size).by(-2)
  end

  describe "Pre-Packaged Exceptions" do
    subject{ Rack::Rescue::Exceptions.new }
    describe "Not found errors" do
      it{ subject["DataMapper::ObjectNotFoundError"         ].status.should == 404 }
      it{ subject["ActiveRecord::RecordNotFound"            ].status.should == 404 }
      it{ subject["Pancake::Errors::NotFound"               ].status.should == 404 }
      it{ subject["Pancake::Errors::UnknownRouter"          ].status.should == 500 }
      it{ subject["Pancake::Errors::UnknownConfiguration"   ].status.should == 500 }
      it{ subject["Pancake::Errors::Unauthorized"           ].status.should == 401 }
      it{ subject["Pancake::Errors::Forbidden"              ].status.should == 403 }
      it{ subject["Pancake::Errors::Server"                 ].status.should == 500 }
      it{ subject["Pancake::Errors::NotAcceptable"          ].status.should == 406 }
    end
  end
end
