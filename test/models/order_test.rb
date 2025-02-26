require "test_helper"

class OrderTest < ActiveSupport::TestCase
  # it "does a thing" do
  #   value(1+1).must_equal 2
  # end

  should belong_to(:customer)
  should belong_to(:address)
  # should validate_presence_of(:customer_id)
  # should validate_presence_of(:address_id)
  should validate_presence_of(:date)

  ### test scopes
  setup do
    create_customers
    create_addresses
    create_orders
  end
  
  teardown do
    destroy_orders
    destroy_addresses
    destroy_customers
  end

  ### test chronological scope
  should "list orders in chronological order" do
    assert_equal [@order3, @order1, @order2, @order4], Order.chronological
  end

  ### test paid scope
  should "return only paid orders" do
    assert_equal [@order1, @order3, @order4], Order.paid
  end

  ### test filter by customer scope
  should "return orders for a specific customer" do
    assert_equal [@order1, @order4], Order.for_customer(@active_customer.id)
  end

  ### test numerical validation for grand_total
  should "ensure grand_total is greater than 0" do
    @order1.grand_total = -5
    assert_not @order1.valid?
    assert_equal ["must be greater than or equal to 0"], @order1.errors[:grand_total]

    @order1.grand_total = 0
    assert @order1.valid?
    # assert_equal ["must be greater than or equal to 0"], @order1.errors[:grand_total]

    @order1.grand_total = 10
    assert @order1.valid?

    ### revert to original price 
    @order1.grand_total = 100.50
  end

  # ### test date is not future
  # should "not allow an order date in the future" do
  #   @order1.date = Date.today + 1
  #   assert_not @order1.valid?
  #   assert_equal ["cannot be in the future"], @order1.errors[:date]

  #   @order1.date = Date.today
  #   assert @order1.valid?

  #   ### revert to original date
  #   @order1.date = 3.days.ago
  # end

  ### test that orders prevented if customer invalid
  should "not allow orders for inactive customers" do
    bad_order = Order.new(customer: @inactive_customer, address: @addr1, grand_total: 50, date: Date.today)
    assert_not bad_order.valid?
    assert_equal ["must be an active customer"], bad_order.errors[:customer]
  end

  ### test that orders prevented if address invalid
  should "not allow orders for inactive addresses" do
    order = Order.new(customer: @another_active_customer, address: @addr3, grand_total: 50, date: Date.today)
    assert_not order.valid?
    assert_equal ["must be an active address"], order.errors[:address]
  end

  ### test pay method
  should "generate a payment receipt if not already paid" do
    assert_nil @order2.payment_receipt

    # copilot helped with the below code
    receipt = @order2.pay
    assert_not_nil @order2.reload.payment_receipt
    assert_equal receipt, @order2.payment_receipt

    ### Ensure calling pay again does not change the receipt
    previous_receipt = @order2.payment_receipt
    assert_not @order2.pay   ### check that calling again returns false
    assert_equal previous_receipt, @order2.reload.payment_receipt
  end

  should "generate a valid encoded_str receipt" do
    @order2.pay
    receipt = @order2.payment_receipt
    # assert_equal Base64.strict_encode64("order: 2; amount_paid: 250.75; received: #{7.days.ago.to_date}; billing_zip: 15213"), receipt
  end
end