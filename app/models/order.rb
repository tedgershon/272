require 'base64'

class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :address

  ### ensure 1-1 for customer -> order (order can have one customer)
  # validates_presence_of :customer_id
  # validates_presence_of :customer
  ### ensure 1-1 for address -> order (order can have one address)
  # validates_presence_of :address_id
  # validates_presence_of :address
  validates_presence_of :date
  validates_date :date
  # validates_presence_of :grand_total
  # ### below code sourced from PATS (procedure.rb to be specific)
  validates_numericality_of :grand_total, :greater_than_or_equal_to => 0
  # ### custom validations:
  validate :customer_must_be_active
  validate :address_must_be_active
  # validate :date_not_in_future # check that date is in past / present

  ### add scopes
  scope :chronological, -> { order(date: :DESC) }  #descending "date: :desc"
  # consulted copilot for the below: asked how to format a non-null receipt value
  scope :paid, -> { where.not(payment_receipt: nil) }
  scope :for_customer, ->(customer_id) { where(customer_id: customer_id) }

  def pay
    # return false if payment_receipt.present?
    if !self.payment_receipt.nil?
      return false 
    else
      # below line initally written with help to Copilot, though modified when it output 7 errors in CLI
      encoded_str = Base64.encode64("order: #{self.id}; amount_paid: #{self.grand_total}; received: #{self.date}; billing_zip: #{self.customer.billing_address.zip}")
      ### returns the "encoded string as verification"
      self.update_column(:payment_receipt, encoded_str)
      return encoded_str
    end
  end

  ### private methods
  private
  # def date_not_in_future
  #   if date.present? && date > Date.today
  #     errors.add(:date, "cannot be in the future")
  #   end
  # end

  def customer_must_be_active
    ### below code copied from PATS
    active_customers = Customer.active.all.map{|c| c.id}
    unless active_customers.include?(self.customer_id)
      errors.add(:customer, "must be an active customer")
    end
    # if customer.nil? || !customer.active
    #   errors.add(:customer_id, "must be an active customer")
    # end
  end

  def address_must_be_active
    ### below code copied from PATS
    active_addresses = Address.active.all.map{|c| c.id}
    unless active_addresses.include?(self.address_id)
      errors.add(:address, "must be an active address")
    end
    # if address.nil? || !address.active
    #   errors.add(:address_id, "must be an active address")
    # end
  end
end