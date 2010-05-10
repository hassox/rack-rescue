module Rack
  class Rescue
    class Handler
      include Pancake::Mixins::Render

      # Setup the default root for the error templates
      roots << ::File.join(::File.expand_path(::File.dirname(__FILE__)), "templates")
      push_paths(:error_templates, "rack_rescue_templates", "**/*")

      attr_accessor :exception, :status, :default_template, :default_format
      attr_reader   :name

      # Rack::Rescue::Handler looks for templates in the form
      #   <template_name>.<format>.<engine_name>
      #
      # By default, the format is :text, but you can configure this to be any format you like
      # @see Rack::Rescue::Handler.default_format=
      # @api public
      def self.default_format
        @default_format ||= :text
      end

      # Set the default format to format of your chosing
      #
      # @example
      #   Rack::Rescue::Handler.default_format = :html
      #
      # @see Rack::Rescue::Handler.default_format
      # @api public
      def self.default_format=(format)
        @default_format = format
      end

      # Looks to se if a template is avaialble
      #
      # @example
      #   Rack::Rescue::Handler.template?(:obscure_error, :format => :html)
      #
      # @see Pancake::Mixins::Render::ClassMethods#template
      def self.template?(name, opts = {})
        !!template(name, opts)
      rescue Pancake::Mixins::Render::TemplateNotFound
        false
      end

      # The defaule path name for the paths_for label
      #
      # @example
      #   Rack::Rescue::Handler.push_paths(:error_templates, ".", "**/*")
      #   Rack::Rescue::Handler._template_path_name should return :error_templates
      #
      # @see Pancake::Mixins::Render::ClassMethods._template_path_name
      # @api overwritable
      def self._template_path_name(opts = {})
        :error_templates
      end

      # Provides the name for the template with the relevant options
      #
      # The template name should be the filename of the template up and until the extension for the template engine.
      #
      # @example
      #   # To find a template: my_template.html.erb
      #
      # Rack::Rescue::Handler._template_name_for("my_template", :format => :html) #=> "my_template.html"
      # @see Pancake::Mixins::Render::ClassMethods._template_name_for
      # @api overwritable
      def self._template_name_for(name,opts)
        format = opts.fetch(:format, default_format)
        "#{name}.#{format}"
      end

      def initialize(exception, opts = {}, &blk)
        @exception  = exception
        @name       = Exceptions.exception_name(exception)
        @status     = opts.fetch(:status, 500)
        @default_template   = opts.fetch(:template, 'error')
        @default_format     = opts[:format] if opts[:format]
      end

      # The main workhorse of the handler
      # This should be called with the error you want to render.
      # The error will be provided to the template in the local "error" variable
      # @api private
      def render_error(error, opts = {})
        opts = opts.dup
        template_name = opts.fetch(:template_name, default_template)
        opts[:format] ||= default_format || self.class.default_format
        opts[:error]  ||= error

        if self.class.template?(template_name, opts)
          tn = template_name
        else
          tn = 'error'
          unless self.class.template?(tn, opts)
            opts[:format] = :text
          end
        end

        render(tn, opts)
      end
    end
  end
end
