module Contexts
  module Customers

    def create_customers
      # enlisted copilot's help to generate random data, then edited date to use factory bot syntax instead
      ### Note that created order is different from last name alphabetical
      @active_customer = FactoryBot.create(:customer, first_name: "Alice", last_name: "Anderson", email: "alice@example.com", phone: "1234567890", active: true)
      @inactive_customer = FactoryBot.create(:customer, first_name: "Bob", last_name: "Brown", email: "bob@example.com", phone: "0987654321", active: false)
      @another_active_customer = FactoryBot.create(:customer, first_name: "Charlie", last_name: "Adams", email: "charlie@example.com", phone: "1112223333", active: true)
      @active_dennis = FactoryBot.create(:customer, first_name: "Dennis", last_name: "Doberman", email: "denny@example.com", phone: "3456789012", active: true)
    end
    
    def destroy_customers
      @active_customer.delete
      @inactive_customer.delete
      @another_active_customer.delete
      @active_dennis.delete
    end

  end
end