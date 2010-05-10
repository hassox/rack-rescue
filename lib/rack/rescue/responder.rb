module Rack
  class Rescue
    class Responder
      include Pancake::Mixins::RequestHelper
      include Pancake::Mixins::ResponseHelper

      def initialize(env, rescuer)
        @rescuer = rescuer
        @env = env
      end

      def negotiate!(opts = {})
        negotiate_content_type!(@rescuer.formats, opts)
      rescue Pancake::Errors::NotAcceptable
        mt = Pancake::MimeTypes.group(:text).first
        headers["Content-Type"] = mt.type_strings.first
        :text
      end
    end
  end
end
