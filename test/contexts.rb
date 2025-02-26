  # require needed files
require './test/sets/customers'
require './test/sets/addresses'
require './test/sets/orders'

module Contexts
  # explicitly include all sets of contexts used for testing 
  include Contexts::Customers
  include Contexts::Addresses
  include Contexts::Orders

  def create_all
    puts "Built customers"
    create_customers
    puts "Built addresses"
    create_addresses
    puts "Built orders"
    create_orders
  end
  
end