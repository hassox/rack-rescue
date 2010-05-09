module Rack
  # Rack Middleware for rescuing exceptions and responding to the client
  # With a page that is descriptive
  class Rescue
    autoload :Exceptions, 'rack/rescue/default_exceptions'
    autoload :Handler,    'rack/rescue/handler'

    def initialize(app, options)
      @app = app
      @exceptions_map = Exceptions.new(options)
      yield @exceptions_map if block_given?
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      if handler = @exceptions_map[e]
        handler.handle(handler, e)
      else
        raise e.class, e.message, e.backtrace
      end
    end
  end
end
