module Rack
  class Rescue
    class Handler
      DEFAULT_HANDLER = Proc.new{|env,error|
      }
      attr_accessor :exception, :status
      attr_reader   :handler, :name
      def initialize(exception, opts = {}, &blk)
        @exception  = exception
        @handler    = blk.nil? ? DEFAULT_HANDLER : blk
        @name       = Exceptions.exception_name(exception)
        @status     = opts[:status] || 500
      end
    end
  end
end
