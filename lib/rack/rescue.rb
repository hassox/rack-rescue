module Rack
  # Rack Middleware for rescuing exceptions and responding to the client
  # With a page that is descriptive
  class Rescue
    autoload :Exceptions, 'rack/rescue/default_exceptions'
    autoload :Handler,    'rack/rescue/handler'

    def initialize(app, options = {})
      @app = app
      load_defaults = options.fetch(:load_default_exceptions, true)
      @exceptions_map = Exceptions.new(load_defaults)
      yield @exceptions_map if block_given?
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      if handler = @exceptions_map[e]
        opts = {}
        opts[:env] = env
        resp, status = handler.render_error(e, opts), handler.status
      else
        handler = @exceptions_map[RuntimeError]
        opts = {:format => :text}
        resp, status = handler.render_error(e, opts), handler.status
      end
      Rack::Response.new(resp, status).finish
    end
  end
end
