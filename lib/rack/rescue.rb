require 'pancake'
module Rack
  # Rack Middleware for rescuing exceptions and responding to the client
  # With a page that is descriptive
  class Rescue
    autoload :Exceptions, 'rack/rescue/default_exceptions'
    autoload :Handler,    'rack/rescue/handler'
    autoload :Responder,  'rack/rescue/responder'

    inheritable_inner_classes "Exceptions", "Handler", "Responder"
    class_inheritable_accessor :error_handlers
    self.error_handlers = []

    # Make sure there are a minimum set of formats available
    [:html, :xml, :text, :js, :json].each do |f|
      ::Pancake::MimeTypes.group(f)
    end

    def self.default_formats
      return @default_formats if @default_formats

      if ENV['RACK_ENV'] == 'production'
        @default_formats = Pancake::MimeTypes.groups.keys.map(&:to_sym)
      else
        Pancake::MimeTypes.groups.keys.map(&:to_sym)
      end
    end

    def self.add_handler(&blk)
      error_handlers << blk
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
      handle_exception(env, e)
    end

    private
    # Apply the layout if it exists
    # @api private
    def apply_layout(env, content, opts)
      if layout = env['layout']
        layout.format = opts[:format]
        layout.content = content
        layout.template_name = opts[:layout] if layout.template_name?(opts[:layout], opts)
        layout
      else
        content
      end
    end

    def handle_exception(env, e)
      # negotiate the content
      request = Rack::Request.new(env)
      responder = Responder.new(env, self)
      opts = {}
      if request.path =~ /\.(.\w)$/
        opts[:format] = $1
      end
      responder.negotiate! opts

      opts[:format] = responder.content_type
      opts[:layout] ||= 'error'

      self.class.error_handlers.each{|blk| blk.call(e, env, opts)}

      handler = @exceptions_map[e].nil? ? @exceptions_map[RuntimeError] : @exceptions_map[e]

      resp, status = handler.render_error(e, opts), handler.status

      response = apply_layout(env, resp, opts)

      Rack::Response.new(response, status, responder.headers).finish
    end
  end
end
