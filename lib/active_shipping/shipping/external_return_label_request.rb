module ActiveMerchant #:nodoc:
  module Shipping #:nodoc:

    class ExternalReturnLabelRequest

      CAP_STRING_LEN = 100

      USPS_EMAIL_REGEX = /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/

      LABEL_FORMAT = {
        'Instructions' => 'null',
        'No Instructions' => 'NOI',
        'Double Label' => 'TWO'
      }

      SERVICE_TYPE_CODE = [
        '044', '019', '596', '020', '597','022', '024', '017', '018'
      ]

      CALL_CENTER_OR_SELF_SERVICE = ['CallCenter', 'Customer']

      LABEL_DEFINITION = ['4X6', 'Zebra-4X6', '4X4', '3X6']

      IMAGE_TYPE = ['PDF', 'TIF']

      attr_reader :customer_name,
                  :customer_address1,
                  :customer_address2,
                  :customer_city,
                  :customer_state,
                  :customer_zipcode,
                  :customer_urbanization,
                  :company_name,
                  :attention,
                  :label_format,
                  :label_definition,
                  :service_type_code,
                  :merchandise_description,
                  :insurance_amount,
                  :address_override_notification,
                  :packaging_information,
                  :packaging_information2,
                  :call_center_or_self_service,
                  :image_type,
                  :address_validation,
                  :sender_name,
                  :sender_email,
                  :recipient_name,
                  :recipient_email,
                  :recipient_bcc,
                  :merchant_account_id,
                  :mid

      def initialize(options = {})
        options.each do |pair|
          # TODO: Do we need to handle non-existent options
          self.send("#{pair[0]}=".to_sym, pair[1]) if self.respond_to?("#{pair[0]}=".to_sym)
        end

        verify_or_raise_required
      end

      def self.from_hash(options={})
        self.new(options)
      end

      def to_bool(v, default = false)
        v = v.to_s
        if v =~ (/(true|yes|1)$/i)
          true
        elsif v =~ (/(false|no|0)$/i)
          false
        else
          default
        end
      end

      def sanitize(v)
        if v.is_a?(String)
          v.strip!
          v[0..CAP_STRING_LEN - 1]
        else
          nil
        end
      end

      # Sent by the system containing the returns label attachment and message.
      def recipient_bcc=(v)
        @recipient_bcc = nil
        if (v = sanitize(v)) && v =~ USPS_EMAIL_REGEX
          @recipient_bcc = v
        else
          raise USPSValidationError, "'#{v}' is not a valid e-mail in #{__method__}"
        end
      end

      # Sent by the system containing the returns label attachment and message.
      # <em>Optional</em>.
      def recipient_email=(v)
        @recipient_email = nil
        if (v = sanitize(v)) && v =~ USPS_EMAIL_REGEX
          @recipient_email = v
        else
          raise USPSValidationError, "'#{v}' is not a valid e-mail in #{__method__}"
        end
      end

      # The name in an email sent by the system containing the returns label attachment.
      # <em>Optional</em>.
      def recipient_name=(v)
        @recipient_name = nil
        if (v = sanitize(v)) && v.length > 0
          @recipient_name = v
        else
          raise USPSValidationError, "'#{v}' is not a valid string in #{__method__}"
        end
      end

      # The From address in an email sent by the system containing the returns
      # label attachment and message, Defaults to DONOTREPLY@USPSReturns.com
      # if a recipient email is entered and a sender email is not.
      # <em>Optional</em>.
      def sender_email=(v)
        @sender_email = nil
        if (v = sanitize(v)) && v =~ USPS_EMAIL_REGEX
          @sender_email = v
        else
          raise USPSValidationError, "'#{v}' is not a valid e-mail in #{__method__}"
        end
      end

      # The From name in an email sent by the system containing the returns
      # label attachment.  Defaults to “Merchant Returns” if a recipient name
      # is entered and a sender name is not.
      # <em>Optional</em>.
      def sender_name=(v)
        @sender_name = nil
        if (v = sanitize(v)) && v.length > 0
          @sender_name = v
        else
          raise USPSValidationError, "'#{v}' is not a valid string in #{__method__}"
        end
      end

      # Used to override the validation of the customer address.
      # If true, the address will be validated against WebTools.
      # If false, the system will bypass the validation.
      # <em>Optional</em>.
      def address_validation=(v)
        @address_validation = to_bool(v, true)
      end

      # Used to select the format of the return label.
      # <em>Optional</em>.
      # * PDF <em>Default</em>.
      # * TIF
      def image_type=(v)
        @image_type = nil
        v = v.to_s.upcase
        if IMAGE_TYPE.include?(v)
          @image_type = v
        else
          raise USPSValidationError, "'#{v}' is not a valid value in #{__method__}, try #{IMAGE_TYPE.join(',')}"
        end
      end

      # Used to determine if the returns label request is coming from a
      # merchant call center agent or an end customer.
      # <b>Required</b>.
      # [CallCenter]
      # [Customer]
      def call_center_or_self_service=(v)
        @call_center_or_self_service = nil
        if CALL_CENTER_OR_SELF_SERVICE.include?(v)
          @call_center_or_self_service = v
        else
          raise USPSValidationError, "'#{v}' is not valid value in #{__method__}, try any one of the following: #{CALL_CENTER_OR_SELF_SERVICE.join(',')}"
        end
      end

      # Package information can be one of three types: RMA, Invoice or
      # Order number. This will appear on the second label generated when
      # the LabelFormat “TWO” is selected.
      # <em>Optional</em>.
      def packaging_information2=(v)
        @packaging_information2 = nil
        if (v = sanitize(v)) && v.size <= 15
          @packaging_information2 = v
        else
          raise USPSValidationError, "#{__method__} must be a String no longer than 15 chars, found value '#{v}'."
        end
      end

      # Package information can be one of three types: RMA, Invoice or
      # Order number. This will appear on the generated label.
      # <em>Optional</em>.
      def packaging_information=(v)
        @packaging_information = nil
        if (v = sanitize(v)) && v.size <= 15
          @packaging_information = v
        else
          raise USPSValidationError, "#{__method__} must be a String no longer than 15 chars, found value '#{v}'."
        end
      end

      # Override address if more address information
      # is needed or system cannot find address. If
      # the address_override_notification value is
      # true then any address error being passed from
      # WebTools would be bypassed and a successful
      # response will be sent.
      # <b>Required</b>.
      def address_override_notification=(v)
        @address_validation = to_bool(v)
      end

      # Insured amount of package.
      def insurance_amount=(v)
        @insurance_amount = nil
        if (1..200).include?(v.to_f)
          @insurance_amount = v
        else
          raise USPSValidationError, "#{__method__} must be a numerical value between 1 and 200, found value '#{v}'."
        end
      end

      # Description of the merchandise.
      # <em>Optional</em>.
      def merchandise_description=(v)
        @merchandise_description = nil
        if (v = sanitize(v)) && v.length <= 255
          @merchandise_description = v
        else
          raise USPSValidationError, "#{__method__} must be a string less than 256 chars, found value '#{v}'."
        end
      end

      # Service type of the label as specified in the merchant profile setup.
      # <b>Required</b>.
      # [044] (Parcel Return Service)
      # [019] (Priority Mail Returns service)
      # [596] (Priority Mail Returns service, Insurance <= $200)
      # [020] (First-Class Package Return service)
      # [597] (First-Class Package Return service, Insurance <= $200)
      # [022] (Ground Return Service)
      # [024] (PRS – Full Network)
      # [017] (PRS – Full Network, Insurance <=$200)
      # [018] (PRS – Full Network, Insurance >$200)
      def service_type_code=(v)
        @service_type_code = nil
        if SERVICE_TYPE_CODE.include?(v)
          @service_type_code = v
        else
          raise USPSValidationError, "#{v} is not valid in #{__method__}, try any of the following: #{SERVICE_TYPE_CODE.join(',')}"
        end
      end

      # Size of the label.
      # <b>Required</b>.
      # * 4X6
      # * Zebra-4X6
      # * 4X4
      # * 3X6
      def label_definition=(v)
        @label_definition = nil
        if LABEL_DEFINITION.include?(v)
          @label_definition = v
        else
          raise USPSValidationError, "#{v} is not valid in #{__method__}, try any of the following: #{LABEL_DEFINITION.join(',')}"
        end
      end

      def label_format
        @label_format && LABEL_FORMAT[@label_format]
      end

      # Format in which the label(s) will be printed.
      # * null (“Instructions”)
      # * NOI (“No Instructions”)
      # * TWO (“Double Label”)
      def label_format=(v)
        @label_format = nil
        if LABEL_FORMAT.keys.include?(v)
          @label_format = v
        else
          raise USPSValidationError, "#{v} is not valid in #{__method__}, try any of the following: #{LABEL_FORMAT.keys.join(',')}"
        end
      end

      # The intended recipient of the returned package (e.g. Returns Department).
      # <em>Optional</em>.
      def attention=(v)
        @attention = nil
        if (v = sanitize(v)) && v.length <= 38
          @attention = v
        else
          raise USPSValidationError, "#{__method__} must be a string no more than 38 chars in length, found value '#{v}'."
        end
      end

      # The name of the company to which the package is being returned.
      # <em>Optional</em>.
      def company_name=(v)
        @company_name = nil
        if (v = sanitize(v)) && v.length <= 38
          @company_name = v
        else
          raise USPSValidationError, "#{__method__} must be a String no more than 38 chars in length, found value '#{v}'."
        end
      end

      # <b>Required</b>.
      def merchant_account_id=(v)
        @merchant_account_id = nil
        if v.to_i > 0
          @merchant_account_id = v
        else
          raise USPSValidationError, "#{__method__} must be a valid positive integer, found value '#{v}'."
        end
      end

      # <b>Required</b>.
      def mid=(v)
        @mid = nil
        if v =~ /^\d{6,9}$/
          @mid = v
        else
          raise USPSValidationError, "#{__method__} must be a valid integer between 6 and 9 digits in length, found value '#{v}'."
        end
      end

      # Urbanization of customer returning the package (only applicable to Puerto Rico addresses).
      # <em>Optional</em>.
      def customer_urbanization=(v)
        @customer_urbanization = nil
        if (v = sanitize(v)) && v.length <= 32
          @customer_urbanization = v
        else
          raise USPSValidationError, "#{__method__} must be a String no more than 32 chars in length, found value '#{v}'."
        end
      end

      # Name of customer returning package.
      # <b>Required</b>.
      def customer_name=(v)
        @customer_name = nil
        if (v = sanitize(v)) && (1..32).include?(v.length)
          @customer_name = v
        else
          raise USPSValidationError, "#{__method__} must be a String between 1 and 32 chars in length, found value '#{v}'."
        end
      end

      # Address of the customer returning the package.
      # <b>Required</b>.
      def customer_address1=(v)
        @customer_address1 = nil
        if (v = sanitize(v)) && (1..32).include?(v.length)
          @customer_address1 = v
        else
          raise USPSValidationError, "#{__method__} must be a String between 1 and 32 chars in length, found value '#{v}'."
        end
      end

      # Secondary address unit designator / number of customer
      # returning the package. (such as an apartment or
      # suite number, e.g. APT 202, STE 100)
      def customer_address2=(v)
        @customer_address2 = nil
        if (v = sanitize(v).to_s) && (0..32).include?(v.length)
          if v.length == 0
            @customer_address2 = nil
          else
            @customer_address2 = v
          end
        else
          raise USPSValidationError, "#{__method__} must be a String less than 32 chars in length, found value '#{v}'."
        end
      end

      # City of customer returning the package.
      # <b>Required</b>.
      def customer_city=(v)
        @customer_city = nil
        if (v = sanitize(v)) && (1..32).include?(v.length)
          @customer_city = v
        else
          raise USPSValidationError, "#{__method__} must be a String between 1 and 32 chars in length, found value '#{v}'."
        end
      end

      # State of customer returning the package.
      # <b>Required</b>.
      def customer_state=(v)
        @customer_state = nil
        if (v = sanitize(v)) && v =~ /^[a-zA-Z]{2}$/
          @customer_state = v
        else
          raise USPSValidationError, "#{__method__} must be a String 2 chars in length, found value '#{v}'."
        end
      end

      # Zipcode of customer returning the package.
      # According to the USPS documentation, Zipcode is optional
      # unless <tt>address_override_notification</tt> is true
      # and <tt>address_validation</tt> is set to false.
      # It's probably just easier to require Zipcodes.
      # <b>Required</b>.
      def customer_zipcode=(v)
        @customer_zipcode = nil
        if (v = sanitize(v))
          v = v[0..4]
          if v =~ /^\d{5}$/
            @customer_zipcode = v
          end
        else
          raise USPSValidationError, "#{__method__} must be a 5 digit number, found value '#{v}'."
        end
      end

      def verify_or_raise_required
        raise USPSMissingRequiredTagError.new("MID", "mid") unless mid
        raise USPSMissingRequiredTagError.new("CustomerName", "customer_name") unless customer_name
        raise USPSMissingRequiredTagError.new("CustomerAddress1", "customer_address1") unless customer_address1
        raise USPSMissingRequiredTagError.new("CustomerCity", "customer_city") unless customer_city
        raise USPSMissingRequiredTagError.new("CustomerState", "customer_state") unless customer_state
        raise USPSMissingRequiredTagError.new("CustomerZipCode", "customer_zipcode") unless customer_zipcode
        raise USPSMissingRequiredTagError.new("LabelFormat", "label_format") unless label_format
        raise USPSMissingRequiredTagError.new("LabelDefinition", "label_definition") unless label_definition
        raise USPSMissingRequiredTagError.new("ServiceTypeCode", "service_type_code") unless service_type_code
        raise USPSMissingRequiredTagError.new("MerchantAccountID", "merchant_account_id") unless merchant_account_id
        raise USPSMissingRequiredTagError.new("CallCenterOrSelfService", "call_center_or_self_service") unless call_center_or_self_service
      end

      def to_xml
        xml_request = XmlNode.new('ExternalReturnLabelRequest') do |root_node|
          root_node << XmlNode.new('CustomerName', customer_name)
          root_node << XmlNode.new('CustomerAddress1', customer_address1)
          root_node << XmlNode.new('CustomerAddress2', customer_address2) if customer_address2
          root_node << XmlNode.new('CustomerCity', customer_city)
          root_node << XmlNode.new('CustomerState', customer_state)
          root_node << XmlNode.new('CustomerZipCode', customer_zipcode) if customer_zipcode
          root_node << XmlNode.new('CustomerUrbanization', customer_urbanization) if customer_urbanization

          root_node << XmlNode.new('MerchantAccountID', merchant_account_id)
          root_node << XmlNode.new('MID', mid)

          root_node << XmlNode.new("SenderName", sender_name) if sender_name
          root_node << XmlNode.new("SenderEmail", sender_email) if sender_email

          root_node << XmlNode.new("RecipientName", recipient_name) if recipient_name
          root_node << XmlNode.new("RecipientEmail", recipient_email) if recipient_email
          root_node << XmlNode.new("RecipientBcc", recipient_bcc) if recipient_bcc

          root_node << XmlNode.new('LabelFormat', label_format) if label_format
          root_node << XmlNode.new('LabelDefinition', label_definition) if label_definition
          root_node << XmlNode.new('RecipientBcc', recipient_bcc) if recipient_bcc
          root_node << XmlNode.new('ServiceTypeCode', service_type_code) if service_type_code

          root_node << XmlNode.new('CompanyName', company_name) if company_name
          root_node << XmlNode.new('Attention', attention) if attention

          root_node << XmlNode.new('CallCenterOrSelfService', call_center_or_self_service)

          root_node << XmlNode.new('MerchandiseDescription', merchandise_description) if merchandise_description
          root_node << XmlNode.new('InsuranceAmount', insurance_amount) if insurance_amount

          root_node << XmlNode.new('AddressOverrideNotification', !!address_override_notification)

          root_node << XmlNode.new('PackageInformation', packaging_information) if packaging_information
          root_node << XmlNode.new('PackageInformation2', packaging_information2) if packaging_information2

          root_node << XmlNode.new('CallCenterOrSelfService', call_center_or_self_service)

          root_node << XmlNode.new('ImageType', image_type) if image_type
          root_node << XmlNode.new('AddressValidation', !!address_validation)

          root_node
        end
      end

    end
  end
end
