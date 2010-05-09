module Rack
  class Rescue
    class Exceptions

      # Add default exceptions to handle.
      #
      # @example
      #   Rack::Rescue::Exceptions.add_defaults("MyException", "AnotherException", :status => 404)
      #
      # @api public
      # @see Rack::Rescue::Exceptions::Handler
      # @see Rack::Rescue::Exceptions#add
      def self.add_defaults(*exceptions)
        opts = Hash === exceptions.last ? exceptions.pop : {}
        exceptions.each do |e|
          DEFAULT_HANDLERS << Handler.new(e, opts)
        end
      end

      # Remove a deafult exception from the list
      #
      # @example
      #   Rack::Rescue::Exceptions.remove_defaults("MyException", "AnotherException")
      #   Rack::Rescue::Exceptions.remove_defaults(/MyKindOfException/)
      #
      # @api public
      # @see Rack::Rescue::Exceptions.add_defaults
      def self.remove_defaults(*exceptions)
        removed = []
        exceptions.each do |e|
          DEFAULT_HANDLERS.each do |h|
            match = case  e
            when String
              h.name == e
            when Regexp
              h.name =~ e
            end
            removed << h if match
          end
        end
        removed.each{|r| DEFAULT_HANDLERS.delete(r) }
      end

      # @param load_defaults Load the default list of exceptions into this instance
      def initialize(load_defaults = true)
        @exception_handlers = {}
        load_defaults! if load_defaults
      end

      # Loads the default list of exceptions defined in
      # Rack::Rescue::Exceptions::DEFAULT_HANDLERS
      # @api public
      def load_defaults!
        DEFAULT_HANDLERS.each do |handler|
          exception_handlers[handler.name] = handler
        end
      end

      # Add an exception handler to Rack::Rescue.
      # Whenever Rack::Rescue rescues an exception, it will check it's list to see what to do with it.
      #
      # @param exceptions a list of exceptions with an optional options hash on the end
      #
      # @option :status [Integer] An integer representing the http response code that should be associated with this exception
      #
      # @api public
      # @see Rack::Rescue::Exceptions.add_defaults
      # @see Rack::Rescue::Exceptions::Handler
      def add(*exceptions)
        opts = Hash === exceptions.last ? exceptions.pop : {}
        exceptions.each do |e|
          name = exception_name(e)
          exception_handlers[name] = Handler.new((opts[:status] || 500), e)
        end
      end

      # Remove an exception handler from this instance of Rack::Rescue::Exceptions
      # This will not remove a default handler
      def delete(e)
        exception_handlers.delete(exception_name(e))
      end

      def exception_handlers
        @exception_handlers
      end

      def [](exception)
        exception_handlers[exception_name(exception)]
      end

      def self.exception_name(e)
        case e
        when String
          e
        when Class
          e.name
        else
          e.class.name
        end
      end

      def exception_name(e)
        self.class.exception_name(e)
      end
    end
  end
end
