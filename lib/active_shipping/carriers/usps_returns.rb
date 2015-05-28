require 'cgi'

module ActiveShipping

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
      response = commit(:external_return_label_request, URI.encode(label.to_xml), (options[:test] || false))
      parse_external_return_label_response(response)
    end

    protected

    def parse_external_return_label_response(response)
      tracking_number, postal_routing, return_label, message = '', '', '', '', ''
      xml = Nokogiri::XML(response)
      error = external_return_label_errors(xml)
      if error.is_a?(Hash) && error.size > 0
        message << "#{error[:error][:code]}: #{error[:error][:message]}"
      else
        tracking_number = xml.at('TrackingNumber').try(:text)
        postal_routing = xml.at('PostalRouting').try(:text)
        return_label = xml.at('ReturnLabel').try(:text)
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
      if node = document.respond_to?(:elements) && document.at('*/errors')
        if node.at('ExternalReturnLabelError')
          if message = node.at('ExternalReturnLabelError/InternalErrorDescription').try(:text)
            if code = node.at('ExternalReturnLabelError/InternalErrorNumber').try(:text)
              {:error => {:code => code, :message => message}}
            else
              {:error => {:code => '', :message => message}}
            end
          elsif message = node.at('ExternalReturnLabelError/ExternalErrorDescription').try(:text)
            if code = node.at('ExternalReturnLabelError/ExternalErrorNumber').try(:text)
              {:error => {:code => code, :message => message}}
            else
              {:error => {:code => '', :message => message}}
            end
          end
        else
          {}
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
