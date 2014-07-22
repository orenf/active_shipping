module ActiveMerchant
  module Shipping
    class ResponseContentError < StandardError
      def initialize(exception, content_body)
        super("#{exception.message} \n\n#{content_body}")
      end
    end

    class USPSValidationError < StandardError
    end

    class USPSMissingRequiredTagError < StandardError
      def initialize(tag, prop)
        super("Missing required tag #{tag} set by property #{prop}")
      end
    end
  end
end
