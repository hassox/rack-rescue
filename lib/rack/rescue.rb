require 'pancake'
module Rack
  # Rack Middleware for rescuing exceptions and responding to the client
  # With a page that is descriptive
  class Rescue
    autoload :Exceptions, 'rack/rescue/default_exceptions'
    autoload :Handler,    'rack/rescue/handler'
    autoload :Responder,  'rack/rescue/responder'

    inheritable_inner_classes "Exceptions", "Handler", "Responder"

    # Make sure there are a minimum set of formats available
    [:html, :xml, :text, :js, :json].each do |f|
      ::Pancake::MimeTypes.group(f)
    end


    def self.default_formats
      return @default_formats if @default_formats
      if ENV['RACK_ENV'] == 'production'
        @default_formats = Pancake::MimeTypes.groups.keys.map(&:to_sym)
      else
        formats = Pancake::MimeTypes.groups.keys.map(&:to_sym)
      end
    end

    def initialize(app, options = {})
      @app = app
      load_defaults = options.fetch(:load_default_exceptions, true)
      @exceptions_map = Exceptions.new(load_defaults)
      @formats        = options[:formats]
      yield @exceptions_map if block_given?
    end

    def formats
      @formats || self.class.default_formats
    end

    def formats=(fmts)
      @formats = fmts
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      # negotiate the content
      request = Rack::Request.new(env)
      responder = Responder.new(env, self)
      opts = {}
      opts[:env] = env
      if request.path =~ /\.(.\w)$/
        opts[:format] = $1
      end
      responder.negotiate! opts

      opts[:format] = responder.content_type

      handler = @exceptions_map[e].nil? ? @exceptions_map[RuntimeError] : @exceptions_map[e]
      resp, status = handler.render_error(e, opts), handler.status

      layout = env['layout']
      if layout
        layout.format = opts[:format]
        layout.template_name = :error if layout.template_name?(:error)
        resp = layout
      end

      Rack::Response.new(resp, status, responder.headers).finish
    end
  end
end
