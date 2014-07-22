require 'cgi'

module ActiveMerchant
  module Shipping

    class USPSReturns < Carrier

      self.retry_safe = true

      cattr_reader :name
      @@name = "USPS Returns"

      LIVE_DOMAIN = 'returns.usps.com'
      LIVE_RESOURCE = 'Services/ExternalCreateReturnLabel.svc/ExternalCreateReturnLabel'

      TEST_DOMAINS = { #indexed by security; e.g. TEST_DOMAINS[USE_SSL[:rates]]
        true => 'returns.usps.com',
        false => 'returns.usps.com'
      }

      TEST_RESOURCE = 'Services/ExternalCreateReturnLabel.svc/ExternalCreateReturnLabel'

      API_CODES = {
        :external_return_label_request => 'externalReturnLabelRequest'
      }

      USE_SSL = {
        :external_return_label_request => true
      }

      def requirements
        []
      end

      def external_return_label_request(label, options = {})
        response = commit(:external_return_label_request, URI.encode(label.to_xml.to_s), (options[:test] || false))
        parse_external_return_label_response(response)
      end

      protected

      def parse_external_return_label_response(response)
        tracking_number, postal_routing, return_label, message = '', '', '', '', ''
        xml = REXML::Document.new(response)
        error = external_return_label_errors(xml)
        # tracking_number = xml.elements.collect('*/TrackingNumber') { |e| e }.first.text
        if error.is_a?(Hash) && error.size > 0
          message << "#{error[:error][:code]}: #{error[:error][:message]}"
        else
          ## FIXME: guard against first being nil
          tracking_number = xml.elements.collect('*/TrackingNumber') { |e| e }.first.text
          postal_routing = xml.elements.collect('*/PostalRouting') { |e| e }.first.text
          return_label = xml.elements.collect('*/ReturnLabel') { |e| e }.first.text
        end

        ExternalReturnLabelResponse.new(message.length == 0, message, Hash.from_xml(response),
          :xml => response,
          :carrier => @@name,
          :request => last_request,
          :return_label => return_label,
          :postal_routing => postal_routing,
          :tracking_number => tracking_number
        )
      end

      def external_return_label_errors(document)
        if node = document.respond_to?(:elements) && document.elements['*/errors/']
          if node.elements['ExternalReturnLabelError']
            if message = node.get_text('ExternalReturnLabelError/InternalErrorDescription')
              if code = node.get_text('ExternalReturnLabelError/InternalErrorNumber')
                {:error => {:code => code, :message => message}}
              else
                {:error => {:code => '', :message => message}}
              end
            elsif message = node.get_text('ExternalReturnLabelError/ExternalErrorDescription')
              if code = node.get_text('ExternalReturnLabelError/ExternalErrorNumber')
                {:error => {:code => code, :message => message}}
              else
                {:error => {:code => '', :message => message}}
              end
            end
          else
            {} # Fixme: Shouldn't happen
          end
        else
          {}
        end
      end

      def commit(action, request, test = false)
        ssl_get(request_url(action, request, test))
      end

      def request_url(action, request, test)
        scheme = USE_SSL[action] ? 'https://' : 'http://'
        host = test ? TEST_DOMAINS[USE_SSL[action]] : LIVE_DOMAIN
        resource = test ? TEST_RESOURCE : LIVE_RESOURCE
        "#{scheme}#{host}/#{resource}?#{API_CODES[action]}=#{request}"
      end

    end
  end
end
