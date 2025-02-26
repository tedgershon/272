require "test_helper"

class AddressTest < ActiveSupport::TestCase
  # it "does a thing" do
  #   value(1+1).must_equal 2
  # end

  should belong_to(:customer)
  should have_many(:orders)
  # should validate_presence_of(:customer_id)

  ### test scopes
  context "Creating addresses context" do
    ### code below inspired from pets_test.rb
    setup do
      create_customers
      create_addresses
    end
    
    teardown do
      destroy_addresses
      destroy_customers
    end

    ### test active scope
    should "return only active addresses" do
      assert_equal [@addr1, @addr2, @addy, @addr4], Address.active
    end

    ### test inactive scope
    should "return only inactive addresses" do
      assert_equal [@addr3], Address.inactive
    end

    ### test by_recipient scope
    should "order addresses by recipient name" do
      assert_equal [@addr4, @addr1, @addr2, @addr3, @addy], Address.by_recipient
    end

    ### test by_customer scope
    should "order addresses by customer's last name, then first name" do
      assert_equal [@addy, @addr3, @addr1, @addr4, @addr2], Address.by_customer
    end

    ### test shipping scope
    should "return only shipping addresses" do
      assert_equal [@addr3, @addr4], Address.shipping
    end

    ### test billing scope
    should "return only billing addresses" do
      assert_equal [@addr1, @addr2, @addy], Address.billing
    end

    # ### test customer_id validation
    # should "have a customer_id present" do
    #   address = FactoryBot.build(:address, customer: nil)
    #   assert_not address.valid?
    #   assert_equal ["can't be blank"], address.errors[:customer_id]
    # end

    ### test recipient, street, zip validation
    should "require recipient, street_1, and zip to be present" do
      address = FactoryBot.build(:address, recipient: nil, street_1: nil, zip: nil)
      assert_not address.valid?
      ### check that error messages are being correctly added to errors hash (zip has additional checks)
      assert_equal ["can't be blank"], address.errors[:recipient]
      assert_equal ["can't be blank"], address.errors[:street_1]
      assert_equal ["can't be blank", "should be five digits long"], address.errors[:zip]
    end

    ### test zip validation (digit length)
    should "require zip to be five digits long" do
      address = FactoryBot.build(:address, zip: "1234")
      assert_not address.valid?
      assert_equal ["should be five digits long"], address.errors[:zip]
    end

    ### test state validation (PA / WV)
    should "require state to be PA or WV" do
      address = FactoryBot.build(:address, state: "NY")
      assert_not address.valid?
      assert_equal ["must be in PA or WV"], address.errors[:state]
    end

    # ### test zip validation (PA / WV)
    # should "require zip to be in PA or WV" do
    #   address = FactoryBot.build(:address, zip: "12345")
    #   assert_not address.valid?
    #   assert_equal ["must be a valid PA or WV zip code"], address.errors[:zip]
    # end

    ### test active customer callback
    should "require customer to be active" do
      inactive_customer = FactoryBot.create(:customer, active: false)
      address = FactoryBot.build(:address, customer: inactive_customer)
      assert_not address.valid?
      assert_equal ["customer must be active"], address.errors[:customer]
    end

    ### test duplicate address callback
    should "prevent duplicate addresses for the same customer" do
      existing_address = @addr1
      duplicate_address = FactoryBot.build(:address, customer: @active_customer, recipient: existing_address.recipient, street_1: existing_address.street_1, zip: existing_address.zip)
      assert_not duplicate_address.valid?
      assert_equal ["Duplicate address already exists for this customer"], duplicate_address.errors[:base]
    end

    ### test billing address callback
    # should "prevent deletion of the last billing address" do
    #   refute @addr2.destroy
    #   assert_equal ["Cannot delete the last billing address"], @addr2.errors[:base]
    # end

    ### test billing -> shipping conversion callback
    should "convert existing billing address to shipping when a new billing address is created" do
      existing_address = @addr3
      new_billing_address = FactoryBot.create(:address, customer: @active_customer, recipient: existing_address.recipient, street_1: existing_address.street_1, zip: existing_address.zip, is_billing: true)
      @addr1.reload
      assert_equal false, @addr1.is_billing
      new_billing_address.delete
    end

    ### test already_exists? method
    # copilot wrote this entire method
    should "have an already_exists? method that checks for duplicate addresses" do
      # Test with a duplicate address
      duplicate_address = FactoryBot.build(:address, customer: @active_customer, recipient: @addr4.recipient, street_1: @addr4.street_1, zip: @addr4.zip)
      assert duplicate_address.already_exists?
      # Test with a unique address
      unique_address = FactoryBot.build(:address, customer: @active_customer, recipient: "Unique Recipient", street_1: "123 Unique St", zip: "15213")
      assert_not unique_address.already_exists?
    end

    ### test make_active method
    should "have a make_active method that activates an address" do
      assert_equal false, @addr3.active
      @addr3.make_active
      assert_equal true, @addr3.active
    end

    ### test make_inactive method
    should "have a make_inactive method that deactivates an address" do
      assert_equal true, @addr4.active
      @addr4.make_inactive
      assert_equal false, @addr4.active
    end

    ### test that can't create inactive first address
    should "test that can't make first address inactive" do
      Bob = FactoryBot.create(:customer, first_name: "Jimothy", last_name: "Gu", phone: "(123) 456-7890")
      nonvalid_address = FactoryBot.build(:address, active: false, recipient: "Felix Frank", street_1: '743 Ben Street', city: 'North Greenbush', state: 'PA', zip: '12144', customer: Bob)
      deny nonvalid_address.valid?
    end

    ### test that can't make billing shipping
    should "test that can't make billing to shipping conversion" do
      @addr2.is_billing = false
      deny @addr2.valid?
    end

    ### test that can't make billing inactive
    should "test that can't make billing inactive" do
      @addr2.active = false
      deny @addr2.valid?
    end

    ### test that billing becomes shipping when shipping becomes billing (callback)
    should "test that billing becomes shipping when shipping becomes billing (callback)" do
      @addr4.is_billing = true
      @addr4.save
      assert_equal false,@addr1.reload.is_billing
    end

  end

end