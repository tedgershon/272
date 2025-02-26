module Contexts
  module Orders

    def create_orders
      # enlisted copilot's help to generate random data, then edited date to use factory bot syntax instead
      ### Note that created order is different from last name alphabetical
      @order1 = FactoryBot.create(:order, customer: @active_customer, address: @addr1, date: 3.days.ago, grand_total: 100.50, payment_receipt: "PAY123456")
      ### the order below is unpaid
      @order2 = FactoryBot.create(:order, customer: @active_dennis, address: @addr2, date: 7.days.ago, grand_total: 250.75, payment_receipt: nil)
      @order3 = FactoryBot.create(:order, customer: @another_active_customer, address: @addr4, date: 1.day.ago, grand_total: 50.00, payment_receipt: "PAY654321")
      @order4 = FactoryBot.create(:order, customer: @active_customer, address: @addr4, date: 10.days.ago, grand_total: 500.00, payment_receipt: "PAY789012")
    end
    
    def destroy_orders
      @order1.delete
      @order2.delete
      @order3.delete
      @order4.delete
    end

  end
end