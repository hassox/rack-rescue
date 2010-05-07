module Rack
  class Rescue
    autoload :Exceptions, 'rack/rescue/default_exceptions'

    def initialize(app, options)
      @app = app
      @exceptions_map = options.inject({}) do |exceptions_map, (exception_types, status_code)|
        Array(exception_types).each {|exception_type| exceptions_map[exceptions_type.to_s] = status_code}
        exceptions_map
      end
    end

    def call(env)
      response = @app.call(env)
    rescue Exception => e
      e_class = e.class.to_s
      if @exceptions_map.key?(e_class)
        [@exceptions_map[e_class], {} ,[]]
      else
        raise e
      end
    end
  end
end
