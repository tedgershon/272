module Contexts
  module Addresses

    def create_addresses
      # enlisted copilot's help to generate random data, then edited date to use factory bot syntax instead
      ### Note that created order is different from last name alphabetical
      @addr1 = FactoryBot.create(:address, customer: @active_customer, recipient: "Alice Anderson", is_billing: true, active: true)
      @addr2 = FactoryBot.create(:address, customer: @active_dennis, recipient: "Bob Brown", is_billing: true, active: true)
      @addy = FactoryBot.create(:address, customer: @another_active_customer, recipient: "Mildred Money", is_billing: true, active: true)
      @addr3 = FactoryBot.create(:address, customer: @another_active_customer, recipient: "Charlie Adams", is_billing: false, active: false)
      @addr4 = FactoryBot.create(:address, customer: @active_customer, recipient: "Abigail Doe", is_billing: false, active: true)
    end
    
    def destroy_addresses
      @addr4.delete
      @addr3.delete
      @addy.delete
      @addr1.delete
      @addr2.delete
    end

  end
end