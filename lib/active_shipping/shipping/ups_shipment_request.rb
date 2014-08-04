# -*- coding: utf-8 -*-
module ActiveMerchant #:nodoc:
  module Shipping #:nodoc:

    class UpsShipmentRequest

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
      end

      def build_address_node(options)
        XmlNode.new('Address') do |address|
          address << XmlNode.new('AddressLine', )
          address << XmlNode.new('City', )
          address << XmlNode.new('Town', )
          address << XmlNode.new('StateProvinceCode', )
          address << XmlNode.new('PostalCode', )
          address << XmlNode.new('CountryCode', )
          address << XmlNode.new('ResidentialAddressIndicator',)
          address << XmlNode.new('POBoxIndicator',)
        end
      end

      def build_email_node(options)
        XmlNode.new('EMail') |email| do
          email << XmlNode.new('EMailAddress',)
          email << XmlNode.new('UndeliverableEMailAddress',)
          email << XmlNode.new('FromEMailAddress',)
          email << XmlNode.new('FromName',)
          email << XmlNode.new('Memo',)
          email << XmlNode.new('Subject',)
          email << XmlNode.new('SubjectCode',)
        end
      end

      def build_payment_information_node(options)
        XmlNode.new('PaymentInformation') do |payment_information|
          payment_information << XmlNode.new('ShipmentCharge') do |shipment_charge|
            shipment_charge << XmlNode.new('Type',)
            shipment_charge << XmlNode.new('BillShipper') do |bill_shipper|
              bill_shipper << XmlNode.new('AccountNumber',)
              bill_shipper << XmlNode.new('CreditCard') do |credit_card|
                credit_card << XmlNode.new('Type', )
                credit_card << XmlNode.new('Number', )
                credit_card << XmlNode.new('ExpirationDate', )
                credit_card << XmlNode.new('SecurityCode', )
                credit_card << build_address_node()
              end
              bill_shipper << XmlNode.new('BillReceiver') do |bill_receiver|
                bill_receiver << XmlNode.new('AccountNumber',)
                # PostalCode
                bill_receiver << build_address_node
              end
            end
            shipment_charge << XmlNode.new('BillThirdParty') do |bill_third_party|
              bill_third_party << XmlNode.new('AccountNumber', )
              # PostalCode, CountryCode
              bill_third_party << build_address_node
            end
            shipment_charge << XmlNode.new('ConsigneeBilledIndicator',)
          end
          payment_information << XmlNode.new('SplitDutyVATIndicator',)
        end
      end

      def build_shipper_node(options)
        XmlNode.new('Shipper') do |shipper|
          shipper << XmlNode.new('Name', )
          shipper << XmlNode.new('AttentionName', )
          shipper << XmlNode.new('CompanyDisplayableName', )
          shipper << XmlNode.new('TaxIdentificationNumber', )
          shipper << XmlNode.new('Phone') do |phone|
            phone << XmlNode.new('Number', '')
            phone << XmlNode.new('Extension', '')
          end
          shipper << XmlNode.new('ShipperNumber', )
          shipper << XmlNode.new('FaxNumber', )
          shipper << XmlNode.new('EMailAddress', )
          shipper << build_address_node()
        end
      end

      def build_ship_to_node(options)
        XmlNode.new('ShipTo') do |ship_to|
          ship_to << XmlNode.new('Name', )
          ship_to << XmlNode.new('AttentionName', )
          ship_to << XmlNode.new('CompanyDisplayableName', )
          ship_to << XmlNode.new('TaxIdentificationNumber', )
          ship_to << XmlNode.new('Phone', ) do |phone|
            phone << XmlNode.new('Number', '')
            phone << XmlNode.new('Extension', '')
          end
          ship_to << XmlNode.new('FaxNumber', )
          ship_to << XmlNode.new('EMailAddress', )
          ship_to << build_address_node()
          ship_to << XmlNode.new('LocationID', )
        end
      end

      def build_ship_from_node(options)
        XmlNode.new('ShipFrom') do |ship_from|
          ship_from << XmlNode.new('Name', )
          ship_from << XmlNode.new('AttentionName', )
          ship_from << XmlNode.new('CompanyDisplayableName', )
          ship_from << XmlNode.new('TaxIdentificationNumber', )
          ship_from << XmlNode.new('TaxIDType') do |tax_id_type|
            tax_id_type << XmlNode.new('Code',)
            tax_id_type << XmlNode.new('Description',)
          end
          ship_from << XmlNode.new('Phone', ) do |phone|
            phone << XmlNode.new('Number', '')
            phone << XmlNode.new('Extension', '')
          end
          ship_from << XmlNode.new('FaxNumber', )
          ship_from << build_address_node()
        end
      end

      def build_alternate_delivery_address(options)
        XmlNode.new('AlternateDeliveryAddress') do |alternate_delivery_address|
          alternate_delivery_address << XmlNode.new('Name', )
          alternate_delivery_address << XmlNode.new('AttentionName', )
          alternate_delivery_address << XmlNode.new('UPSAccessPointID',)
          alternate_delivery_address << build_address_node()
        end
      end

      def build_frs_payment_information(options)
        XmlNode.new('FRSPaymentInformation') do |frs_payment_information|
          frs_payment_information << XmlNode.new('Type') do |type|
            type << XmlNode.new('Code', )
            type << XmlNode.new('Description', )
          end
          frs_payment_information << XmlNode.new('AccountNumber', )
          # PostalCode, CountryCode
          frs_payment_information << build_address_node
        end
      end

      def build_shipment_rating_options(options)
        XmlNode.new('ShipmentRatingOptions') do |shipment_rating_options|
          shipment_rating_options << XmlNode.new('NegotiatedRatesIndicator',)
          shipment_rating_options << XmlNode.new('FRSShipmentIndicator',)
          shipment_rating_options << XmlNode.new('RateChartIndicator',)
        end
      end

      def build_reference_number(options)
        XmlNode.new('ReferenceNumber') do |reference_number|
          reference_number << XmlNode.new('BarCodeIndicator',)
          reference_number << XmlNode.new('Code',)
          reference_number << XmlNode.new('Value',)
        end
      end

      def build_international_forms(options)
        XmlNode.new('InternationalForms') do |international_forms|
          international_forms << XmlNode.new('FormType')
          international_forms << XmlNode.new('CN22Form') do |cn22_form|
            cn22_form << XmlNode.new('LabelSize',)
            cn22_form << XmlNode.new('PrintsPerPage',)
            cn22_form << XmlNode.new('LabelPrintType',)
            cn22_form << XmlNode.new('CN22Type',)
            cn22_form << XmlNode.new('CN22OtherDescription',)
            cn22_form << XmlNode.new('FoldHereText',)
            cn22_form << XmlNode.new('CN22Content') |cn22_content| do
              cn22_content << XmlNode.new('CN22ContentQuantity',)
              cn22_content << XmlNode.new('CN22ContentDescription',)
              cn22_content << XmlNode.new('CN22ContentWeight') do |cn22_content_weight|
                cn22_content_weight << XmlNode.new('UnitOfMeasurement') do |unit_of_measurement|
                  unit_of_measurement << XmlNode.new('Code',)
                  unit_of_measurement << XmlNode.new('Description',)
                end
                cn22_content_weight << XmlNode.new('Weight',)
              end
              cn22_content << XmlNode.new('CN22ContentTotalValue',)
              cn22_content << XmlNode.new('CN22ContentCurrencyCode',)
              cn22_content << XmlNode.new('CN22ContentCountryOfOrigin',)
              cn22_content << XmlNode.new('CN22ContentTariffNumber',)
            end
          end
          international_forms << XmlNode.new('UserCreatedForm') do |user_created_form|
            user_created_form << XmlNode.new('DocumentID',)
          end
          international_form << XmlNode.new('AdditionalDocumentIndicator',)
          international_form << XmlNode.new('UPSPremiumCareForm') do |ups_premium_care_form|
            ups_premium_care_form << XmlNode.new('ShipmentDate',)
            ups_premium_care_form << XmlNode.new('PageSize',)
            ups_premium_care_form << XmlNode.new('PrintType',)
            ups_premium_care_form << XmlNode.new('NumOfCopies',)
            ups_premium_care_form << XmlNode.new('LanguageForUPSPremiumCare') do |language_for_ups_premium_care|
              language_for_ups_premium_care << XmlNode.new('Language',)
            end
          end
          international_form << XmlNode.new('FormGroupIdName',)
          international_form << XmlNode.new('EEIFilingOption') do |eei_filing_option|
            eei_filing_option << XmlNode.new('Code',)
            eei_filing_option << XmlNode.new('Description',)
            eei_filing_option << XmlNode.new('EMailAddress',)
            eei_filing_option << XmlNode.new('UPSFiled') do |ups_filed|
              ups_filed << XmlNode.new('POA') do |poa|
                poa << XmlNode.new('Code',)
                poa << XmlNode.new('Description',)
              end
            end
            eei_filing_option << XmlNode.new('ShipperFiled') do |shipper_filed|
              shipper_filed << XmlNode.new('Code',)
              shipper_filed << XmlNode.new('Description',)
            end
            eei_filing_option << XmlNode.new('PreDepartureITNNumber',)
            eei_filing_option << XmlNode.new('ExemptionLegend',)
          end
          international_form << XmlNode.new('Contacts') do |contacts|
            contacts << XmlNode.new('ForwardAgent') do |forward_agent|
              forward_agent << XmlNode.new('CompanyName')
              forward_agent << XmlNode.new('TaxIdentificationNumber')
              forward_agent << build_address_node
            end
            contacts << XmlNode.new('UltimateConsignee') do |ultimate_consignee|
              ultimate_consignee << XmlNode.new('CompanyName',)
              ultimate_consignee << build_address_node
            end
            contacts << XmlNode.new('UltimateConsigneeType') do |ultimate_consignee_type|
              ultimate_consignee_type << XmlNode.new('Code',)
              ultimate_consignee_type << XmlNode.new('Description',)
            end
            contacts << XmlNode.new('IntermediateConsignee') do |intermediate_consignee|
              intermediate_consignee << XmlNode.new('CompanyName')
              intermediate_consignee << build_address_node
            end
            contacts << XmlNode.new('Producer') do |producer|
              producer << XmlNode.new('Option',)
              producer << XmlNode.new('CompanyName',)
              producer << XmlNode.new('TaxIdentificationNumber',)
              producer << build_address_node
              producer << XmlNode.new('AttentionName')
              producer << XmlNode.new('Phone') do |phone|
                phone << XmlNode.new('Number',)
                phone << XmlNode.new('Extension',)
              end
              producer << XmlNode.new('EMailAddress',)
            end
            contacts << XmlNode.new('SoldTo') do |sold_to|
              sold_to << XmlNode.new('Name',)
              sold_to << XmlNode.new('AttentionName',)
              sold_to << XmlNode.new('TaxIdentificationNumber',)
              sold_to << XmlNode.new('Phone') do |phone|
                phone << XmlNode.new('Number',)
                phone << XmlNode.new('Extension',)
              end
              sold_to << XmlNode.new('Option')
              sold_to << build_address_node
              sold_to << XmlNode.new('EMailAddress',)
            end
          end
          international_form << XmlNode.new('Product') do |product|
            product << XmlNode.new('Description',)
            product << XmlNode.new('Unit') do |unit|
              unit << XmlNode.new('Number',)
              unit << XmlNode.new('UnitOfMeasurement') do |unit_of_measurement|
                unit_of_measurement << XmlNode.new('Code',)
                unit_of_measurement << XmlNode.new('Description',)
              end
              unit << XmlNode.new('Value',)
            end
            product << XmlNode.new('CommodityCode',)
            product << XmlNode.new('PartNumber',)
            product << XmlNode.new('OriginCountryCode',)
            product << XmlNode.new('JointProductionIndicator',)
            product << XmlNode.new('NetCostCode',)
            product << XmlNode.new('NetCostDateRange') do |net_cost_date_range|
              net_cost_date_range << XmlNode.new('BeginDate',)
              net_cost_date_range << XmlNode.new('EndDate',)
            end
            product << XmlNode.new('PreferenceCriteria',)
            product << XmlNode.new('ProducerInfo',)
            product << XmlNode.new('MarksAndNumbers',)
            product << XmlNode.new('NumberOfPackagesPerCommodity',)
            product << XmlNode.new('ProductWeight') do |product_weight|
              product_weight << XmlNode.new('UnitOfMeasurement') do |unit_of_measurement|
                unit_of_measurement << XmlNode.new('Code',)
                unit_of_measurement << XmlNode.new('Description',)
              end
              product_weight << XmlNode.new('Weight',)
            end
            product << XmlNode.new('VehicleID',)
            product << XmlNode.new('ScheduleB') do |schedule_b|
              schedule_b << XmlNode.new('Number',)
              schedule_b << XmlNode.new('Quantity',)
              schedule_b << XmlNode.new('UnitOfMeasurement') do |unit_of_measurement|
                unit_of_measurement << XmlNode.new('Code',)
                unit_of_measurement << XmlNode.new('Description',)
              end
            end
            product << XmlNode.new('ExportType',)
            product << XmlNode.new('SEDTotalValue',)
            product << XmlNode.new('EEIInformation') do |eei_information|
              eei_information << XmlNode.new('ExportInformation',)
              eei_information << XmlNode.new('License') do |license|
                license << XmlNode.new('Number',)
                license << XmlNode.new('Code',)
                license << XmlNode.new('LicenseLineValue',)
                license << XmlNode.new('ECCNNumber',)
              end
              eei_information << XmlNode.new('DDTCInformation') do |ddtc_information|
                ddtc_information << XmlNode.new('ITARExemptionNumber',)
                ddtc_information << XmlNode.new('USMLCategoryCode',)
                ddtc_information << XmlNode.new('EligiblePartyIndicator',)
                ddtc_information << XmlNode.new('RegistrationNumber',)
                ddtc_information << XmlNode.new('Quantity',)
                ddtc_information << XmlNode.new('UnitOfMeasurement') do |unit_of_measurement|
                  unit_of_measurement << XmlNode.new('Code',)
                  unit_of_measurement << XmlNode.new('Description',)
                end
                ddtc_information << XmlNode.new('SignificantMilitaryEquipmentIndicator',)
                ddtc_information << XmlNode.new('ACMNumber',)
                ddtc_information << XmlNode.new('ExcludeFromForm') do |exclude_from_form|
                  exclude_from_form << XmlNode.new('FormType',)
                  exclude_from_form << XmlNode.new('PackingListInfo') do |packing_list_info|
                    packing_list_info << XmlNode.new('PackageAssociated') do |package_associated|
                      package_associated << XmlNode.new('PackageNumber',)
                      package_associated << XmlNode.new('ProductAmount',)
                    end
                  end
                end
              end
            end
          end
          international_form << XmlNode.new('InvoiceNumber',)
          international_form << XmlNode.new('InvoiceDate',)
          international_form << XmlNode.new('PurchaseOrderNumber',)
          international_form << XmlNode.new('TermsOfShipment',)
          international_form << XmlNode.new('ReasonForExport',)
          international_form << XmlNode.new('Comments',)
          international_form << XmlNode.new('DeclarationStatement',)
          international_form << XmlNode.new('Discount') do |discount|
            discount << XmlNode.new('MonetaryValue',)
            discount << XmlNode.new('FreightCharges') do |freight_charges|
              freight_charges << XmlNode.new('MonetaryValue',)
            end
          end
          international_form << XmlNode.new('InsuranceCharges') do |insurance_charges|
            insurance_charges << XmlNode.new('MonetaryValue',)
          end
          international_form << XmlNode.new('OtherCharges') do |other_charges|
            other_charges << XmlNode.new('MonetaryValue',)
            other_charges << XmlNode.new('Description',)
          end
          international_form << XmlNode.new('CurrencyCode',)
          international_form << XmlNode.new('BlanketPeriod') do |blanket_period|
            blanket_period << XmlNode.new('BeginDate',)
            blanket_period << XmlNode.new('EndDate',)
          end
          international_form << XmlNode.new('ExportDate',)
          international_form << XmlNode.new('ExportingCarrier',)
          international_form << XmlNode.new('CarrierID',)
          international_form << XmlNode.new('InBondCode',)
          international_form << XmlNode.new('EntryNumber',)
          international_form << XmlNode.new('PointOfOrigin',)
          international_form << XmlNode.new('PointOfOriginType',)
          international_form << XmlNode.new('ModeOfTransport',)
          international_form << XmlNode.new('PortOfExport',)
          international_form << XmlNode.new('PortOfUnloading',)
          international_form << XmlNode.new('LoadingPier',)

          international_form << XmlNode.new('PartiesToTransaction',)
          international_form << XmlNode.new('RoutedExportTransactionIndicator',)
          international_form << XmlNode.new('ContainerizedIndicator',)
          international_form << XmlNode.new('OverridePaperlessIndicator',)

          international_form << XmlNode.new('ShipperMemo',)
        end
      end

      def build_shipment_service_options_node(options)
        XmlNode.new('ShipmentServiceOptions') do |shipment_service_options|
          shipment_service_options << XmlNode.new('SaturdayDeliveryIndicator',)
          shipment_service_options << XmlNode.new('COD') do |cod|
            cod << XmlNode.new('CODFundsCode',)
            cod << XmlNode.new('CODAmount') do |cod_amount|
              cod_amount << XmlNode.new('CurrencyCode', )
              cod_amount << XmlNode.new('MonetaryValue',)
            end
          end
          shipment_service_options << XmlNode.new('AccessPointCOD') do |access_point_cod|
            access_point_cod << XmlNode.new('CurrencyCode', )
            access_point_cod << XmlNode.new('MonetaryValue', )
          end
          shipment_service_options << XmlNode.new('DeliverToAddresseeOnlyIndicator',)
          shipment_service_options << XmlNode.new('Notification') do |notification|
            notification << XmlNode.new('NotificationCode', )
            notification << build_email_node()
            notification << XmlNode.new('VoiceMessage') do |voice_message|
              voice_message << XmlNode.new('PhoneNumber',)
            end
            notification << XmlNode.new('TextMessage') do |text_message|
              text_message << XmlNode.new('PhoneNumber',)
            end
            notification << XmlNode.new('Locale') do |locale|
              locale << XmlNode.new('Language',)
              locale << XmlNode.new('Dialect',)
            end
          end
          shipment_service_options << XmlNode.new('LabelDelivery') do |label_delivery|
            label_delivery << build_email_node()
            label_delivery << XmlNode.new('LabelLinksIndicator', )
          end
          shipment_service_options << build_international_forms

          shipment_service_options << XmlNode.new('DeliveryConfirmation') do |delivery_confirmation|
            delivery_confirmation << XmlNode.new('DCISType',)
            delivery_confirmation << XmlNode.new('DCISNumber',)
          end

          shipment_service_options << XmlNode.new('ReturnOfDocumentIndicator',)
          shipment_service_options << XmlNode.new('ImportControlIndicator',)
          shipment_service_options << XmlNode.new('LabelMethod') do |label_method|
            label_method << XmlNode.new('Code',)
            label_method << XmlNode.new('Description',)
          end

          shipment_service_options << XmlNode.new('CommercialInvoiceRemovalIndicator',)
          shipment_service_options << XmlNode.new('UPScarbonneutralIndicator',)
          shipment_service_options << XmlNode.new('PreAlertNotification') do |pre_alert_notification|
            pre_alert_notification << XmlNode.new('EMailMessage') do |email_message|
              email_message << XmlNode.new('EMailAddress',)
              email_message << XmlNode.new('UndeliverableEMailAddress',)
            end
            pre_alert_notification << XmlNode.new('VoiceMessage') do |voice_message|
              voice_message << XmlNode.new('PhoneNumber',)
            end
            pre_alert_notification << XmlNode.new('TextMessage') do |text_message|
              text_message << XmlNode.new('PhoneNumber',)
            end
            pre_alert_notification << XmlNode.new('Locale') do |locale|
              locale << XmlNode.new('Language',)
              locale << XmlNode.new('Dialect',)
            end
          end
          shipment_service_options << XmlNode.new('ExchangeForwardIndicator',)
          shipment_service_options << XmlNode.new('HoldForPickupIndicator',)
          shipment_service_options << XmlNode.new('DropoffAtUPSFacilityIndicator',)
          shipment_service_options << XmlNode.new('LiftGateForPickUpIndicator',)
          shipment_service_options << XmlNode.new('LiftGateForDeliveryIndicator',)
          shipment_service_options << XmlNode.new('SDLShipmentIndicator',)
        end
      end

      def build_package_node(options)
        XmlNode.new('Package') do |package|
          package << XmlNode.new('Description',)
          package << XmlNode.new('Packaging') do |packaging|
            packaging << XmlNode.new('Code',)
            packaging << XmlNode.new('Description',)
          end
          package << XmlNode.new('Dimensions') do |dimensions|
            dimensions << XmlNode.new('UnitOfMeasurement') do |unit_of_measurement|
              unit_of_measurement << XmlNode.new('Code',)
              unit_of_measurement << XmlNode.new('Description',)
            end
            dimensions << XmlNode.new('Length',)
            dimensions << XmlNode.new('Width',)
            dimensions << XmlNode.new('Height',)
          end
          package << XmlNode.new('PackageWeight') do |package_weight|
            package_weight << XmlNode.new('UnitOfMeasurement') do |unit_of_measurement|
              unit_of_measurement << XmlNode.new('Code',)
              unit_of_measurement << XmlNode.new('Description',)
            end
            package_weight << XmlNode.new('Weight',)
          end
          package << XmlNode.new('LargePackageIndicator',)
          package << XmlNode.new('ReferenceNumber') do |reference_number|
            reference_number << XmlNode.new('BarCodeIndicator',)
            reference_number << XmlNode.new('Code',)
            reference_number << XmlNode.new('Value',)
          end
          package << XmlNode.new('AdditionalHandlingIndicator',)
          package << XmlNode.new('PackageServiceOptions') do |package_service_options|
            package_service_options << XmlNode.new('DeliveryConfirmation') do |delivery_confirmation|
              delivery_confirmation << XmlNode.new('DCISType',)
              delivery_confirmation << XmlNode.new('DCISNumber',)
            end
            package_service_options << XmlNode.new('DeclaredValue') do |declared_value|
              declared_value << XmlNode.new('Type') do |type|
                type << XmlNode.new('Code')
                type << XmlNode.new('Description')
              end
              declared_value << XmlNode.new('CurrencyCode',)
              declared_value << XmlNode.new('MonetaryValue',)
            end
            package_service_options << XmlNode.new('COD') do |cod|
              cod << XmlNode.new('CODFundsCode',)
              cod << XmlNode.new('CODAmount') do |cod_amount|
                cod_amount << XmlNode.new('CurrencyCode', )
                cod_amount << XmlNode.new('MonetaryValue',)
              end
            end
            package_service_options << XmlNode.new('AccessPointCOD') do |access_point_cod|
              access_point_cod << XmlNode.new('CurrencyCode', )
              access_point_cod << XmlNode.new('MonetaryValue',)
            end
            package_service_options << XmlNode.new('VerbalConfirmation') do |verbal_confirmation|
              verbal_confirmation << XmlNode.new('ContactInfo') do |contact_info|
                contact_info << XmlNode.new('Name',)
                contact_info << XmlNode.new('Phone') do |phone|
                  phone << XmlNode.new('Number', '')
                  phone << XmlNode.new('Extension', '')
                end
              end
            end
            package_service_options << XmlNode.new('ShipperReleaseIndicator',)
            package_service_options << XmlNode.new('Notification') do |notification|
              notification << XmlNode.new('NotificationCode', )
              notification << build_email_node()
            end
            package_service_options << XmlNode.new('DryIce') do |dry_ice|
              dry_ice << XmlNode.new('RegulationSet',)
              dry_ice << XmlNode.new('DryIceWeight') do |dry_ice_weight|
                dry_ice_weight << XmlNode.new('UnitOfMeasurement') do |unit_of_measurement|
                  unit_of_measurement << XmlNode.new('Code',)
                  unit_of_measurement << XmlNode.new('Description',)
                end
                dry_ice_weight << XmlNode.new('Weight',)
              end
              dry_ice << XmlNode.new('MedicalUseIndicator',)
            end
            package_service_options << XmlNode.new('UPSPremiumCareIndicator',)
          end
          package << XmlNode.new('Commodity') do |commodity|
            commodity << XmlNode.new('FreightClass',)
            commodity << XmlNode.new('NMFC') do |nmfc|
              nmfc << XmlNode.new('PrimeCode',)
              nmfc << XmlNode.new('SubCode',)
            end
          end
        end
      end

      def to_xml
        xml_request = XmlNode.new('ShipmentRequest') do |root_node|
          root_node << XmlNode.new('Request') do |request|
            request << XmlNode.new('RequestOption', )
            request << XmlNode.new('TransactionReference') do |transaction_reference|
              transaction_reference << XmlNode.new('CustomerContext', )
            end
          end
          root_node << XmlNode.new('Shipment') do |shipment|
            shipment << XmlNode.new('Description', )
            shipment << XmlNode.new('ReturnService') do |return_service|
              return_service << XmlNode.new('Code', )
              return_service << XmlNode.new('Description', )
              return_service << XmlNode.new('DocumentsOnlyIndicator', )
            end
            shipment << build_shipper_node
            shipment << build_ship_to_node
            shipment << build_alternate_delivery_address
            shipment << build_ship_from_node
            shipment << build_payment_information_node
            shipment << build_frs_payment_information

            shipment << XmlNode.new('GoodsNotInFreeCirculationIndicator', )

            shipment << build_shipment_rating_options

            shipment << XmlNode.new('MovementReferenceNumber', )

            shipment << build_reference_number

            shipment << XmlNode.new('Service') do |service|
              service << XmlNode.new('Code',)
              service << XmlNode.new('Description',)
            end

            shipment << XmlNode.new('InvoiceLineTotal') do |invoice_line_total|
              invoice_line_total << XmlNode.new('CurrencyCode',)
              invoice_line_total << XmlNode.new('MonetaryValue',)
            end

            shipment << XmlNode.new('NumOfPiecesInShipment', )
            shipment << XmlNode.new('ItemizedChargesRequestedIndicator', )
            shipment << XmlNode.new('RatingMethodRequestedIndicator', )
            shipment << XmlNode.new('ShipmentIndicationType') do |shipment_indication_type|
              shipment_indication_type << XmlNode.new('Code',)
              shipment_indication_type << XmlNode.new('Description',)
            end
            shipment << XmlNode.new('USPSEndorsement', )
            shipment << XmlNode.new('MILabelCN22Indicator', )
            shipment << XmlNode.new('SubClassification', )
            shipment << XmlNode.new('CostCenter', )
            shipment << XmlNode.new('PackageID', )
            shipment << XmlNode.new('IrregularIndicator', )
            shipment << build_shipment_service_options_node
            shipment << build_package_node
          end

          root_node << XmlNode.new('LabelSpecification') do |label_specification|
            label_specification << XmlNode.new('LabelImageFormat') do |label_image_format|
              label_image_format << XmlNode.new('Code',)
              label_image_format << XmlNode.new('Description',)
            end
            label_specification << XmlNode.new('HTTPUserAgent',)
            label_specification << XmlNode.new('LabelStockSize') do |label_stock_size|
              label_stock_size << XmlNode.new('Height')
              label_stock_size << XmlNode.new('Width')
            end
            label_specification << XmlNode.new('Instruction') do |instruction|
              instruction << XmlNode.new('Code',)
              instruction << XmlNode.new('Description',)
            end
          end

          root_node << XmlNode.new('ReceiptSpecification') do |receipt_specification|
            receipt_specification << XmlNode.new('ImageFormat') do |image_format|
              image_format << XmlNode.new('Code')
              image_format << XmlNode.new('Description')
            end
          end
        end

      end
    end
  end
end
