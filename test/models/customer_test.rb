require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  # it "does a thing" do
  #   value(1+1).must_equal 2
  # end

  should have_many(:orders)
  should have_many(:addresses)
  should validate_presence_of(:first_name)
  should validate_presence_of(:last_name)
  # should validate_presence_of(:phone)

  ### test phone, email validation
  should allow_value("9999999999").for(:phone)
  should allow_value("999-999-9999").for(:phone)
  should allow_value("999.999.9999").for(:phone)
  should allow_value("(999) 999-9999").for(:phone)
  should_not allow_value("123-456-789").for(:phone)
  should_not allow_value("abcdefghij").for(:phone)
  should_not allow_value("12345678901").for(:phone)

  should allow_value("test@example.com").for(:email)
  should_not allow_value("test@example").for(:email)
  should_not allow_value("test.com").for(:email)
  should_not allow_value("@example.com").for(:email)

  ### test scopes
  context "Creating customers context" do
    ### code below inspired from pets_test.rb
    setup do
      create_customers
      ### create addresses for the last billing_address test
      create_addresses
    end
    
    teardown do
      destroy_addresses
      destroy_customers
    end

    ### test active scope
    should "return only active customers" do
      assert_equal [@active_customer, @another_active_customer, @active_dennis], Customer.active
    end

    ### test inactive scope
    should "return only inactive customers" do
      assert_equal [@inactive_customer], Customer.inactive
    end

    ### test alphabetical scope
    should "return customers in alphabetical order by last name, then first name" do
      assert_equal [@another_active_customer, @active_customer, @inactive_customer, @active_dennis], Customer.alphabetical
    end

    ### test phone numbers stripped to string format with only digits stored
    should "strips phone to solely digits before saving" do
      customer1 = FactoryBot.create(:customer, first_name: "Jimothy", last_name: "Gu", phone: "(123) 456-7890")
      assert_equal customer1.phone, "1234567890"
      customer1.delete
    end
    
    ### test additional methods
    should "name returns last_name, first_name" do
      assert_equal @inactive_customer.name, "Brown, Bob"
    end

    should "proper_name returns first_name last_name" do
      assert_equal @inactive_customer.proper_name, "Bob Brown"
    end

    should "make_active updates active to true" do
      @inactive_customer.make_active
      assert_equal true, @inactive_customer.active
    end

    should "make_inactive updates active to false" do
      @inactive_customer.make_inactive
      assert_equal false, @inactive_customer.active
    end

    should "billing_address returns active billing address" do
      assert_equal @active_customer.billing_address, @addr1
    end

  end

end
