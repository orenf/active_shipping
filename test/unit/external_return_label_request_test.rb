require 'test_helper'

class ExternalReturnLabelRequestTest < Minitest::Test
  include ActiveShipping::Test::Fixtures

  def setup
    @external_request_label_req =
      ExternalReturnLabelRequest.from_hash ({
        :customer_name => "Test Customer",
        :customer_address1 => "122 Hudson St.",
        :customer_city => "New York",
        :customer_state => "NY",
        :customer_zipcode => "10013",
        :label_format => "No Instructions",
        :label_definition => "4X6",
        :service_type_code => "044",
        :merchant_account_id => "12345",
        :mid => "12345678",
        :call_center_or_self_service => "Customer",
        :address_override_notification => "true"
      })

  end

  def test_recipient_bcc
    assert_raises(USPSValidationError) do
      @external_request_label_req.recipient_bcc = "not_a_valid_email"
    end
    assert_silent do
      @external_request_label_req.recipient_bcc = "no-reply@chloeandisabel.com"
    end
  end

  def test_recipient_email
    assert_raises(USPSValidationError) do
      @external_request_label_req.recipient_email = "not_a_valid_email"
    end
    assert_silent do
      @external_request_label_req.recipient_email = "no-reply@chloeandisabel.com"
    end
  end

  def test_recipient_name
    assert_silent do
      @external_request_label_req.recipient_name = "any string"
    end
  end

  def test_sender_email
    assert_raises(USPSValidationError) do
      @external_request_label_req.sender_email = "not_a_valid_email"
    end
    assert_silent do
      @external_request_label_req.sender_email = "no-reply@chloeandisabel.com"
    end
  end

  def test_sender_name
    assert_silent do
      @external_request_label_req.sender_name = "any string"
    end
    assert_raises(USPSValidationError) do
      @external_request_label_req.sender_name = ""
    end
  end

  def test_image_type
    assert_silent do
      ExternalReturnLabelRequest::IMAGE_TYPE.each do |img_type|
        @external_request_label_req.image_type = img_type.downcase
      end
    end
    assert_raises(USPSValidationError) do
      @external_request_label_req.image_type = "jpg"
    end
  end

  def test_call_center_or_self_service
    assert_silent do
      ExternalReturnLabelRequest::CALL_CENTER_OR_SELF_SERVICE.each do |cc_or_cs|
        @external_request_label_req.call_center_or_self_service = cc_or_cs
      end
    end
    assert_raises(USPSValidationError) do
      @external_request_label_req.call_center_or_self_service = "Invalid"
    end
  end

  def test_packaging_information
    assert_silent do
      @external_request_label_req.packaging_information = "Any String"
    end
    assert_raises(USPSValidationError) do
      @external_request_label_req.packaging_information = (1..50).to_a.join("_")
    end
  end

  def test_packaging_information2
    assert_silent do
      @external_request_label_req.packaging_information2 = "Any String"
    end
    assert_silent do
      @external_request_label_req.packaging_information2 = " "
      @external_request_label_req.packaging_information2 = ""
    end
    assert_raises(USPSValidationError) do
      @external_request_label_req.packaging_information2 = (1..50).to_a.join("_")
    end
  end

  def test_customer_address2
    assert_silent do
      @external_request_label_req.customer_address2 = "     "
    end
    assert_silent do
      @external_request_label_req.customer_address2 = nil
    end
  end

  def test_sanitize
    assert_equal @external_request_label_req.sanitize('   ').length, 0
    assert_equal @external_request_label_req.sanitize('some string   '), 'some string'
    assert_equal @external_request_label_req.sanitize({}), nil
    assert_equal @external_request_label_req.sanitize(nil), nil
    assert_equal @external_request_label_req.sanitize(nil), nil
    assert_equal @external_request_label_req.sanitize([]), nil
    assert_equal @external_request_label_req.sanitize((1..100).to_a.join("_")).size, ExternalReturnLabelRequest::CAP_STRING_LEN
  end

  def test_to_bool
    assert_equal @external_request_label_req.to_bool('yes'), true
    assert_equal @external_request_label_req.to_bool('true'), true
    assert_equal @external_request_label_req.to_bool(true), true
    assert_equal @external_request_label_req.to_bool('1'), true
    assert_equal @external_request_label_req.to_bool('0'), false
    assert_equal @external_request_label_req.to_bool('false'), false
    assert_equal @external_request_label_req.to_bool(false), false
    assert_equal @external_request_label_req.to_bool(nil, false), false
  end

  def test_tag_required
    assert_raises(USPSMissingRequiredTagError) { ExternalReturnLabelRequest.new }

    sample_hash = {
      :customer_name => "Test Customer",
      :customer_address1 => "122 Hudson St.",
      :customer_city => "New York",
      :customer_state => "NY",
      :customer_zipcode => "10013",
      :label_format => "No Instructions",
      :label_definition => "4X6",
      :service_type_code => "044",
      :merchant_account_id => "12345",
      :mid => "12345678",
      :call_center_or_self_service => "Customer",
      :address_override_notification => "true"
    }

    assert_silent do
      ExternalReturnLabelRequest.from_hash(sample_hash)
    end

    sample_hash.keys.each do |k|
      assert_raises(USPSMissingRequiredTagError) do
        ExternalReturnLabelRequest.from_hash(sample_hash.reject {|k, v| k })
      end
    end
  end

end
