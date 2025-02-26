class Address < ApplicationRecord
  belongs_to :customer
  has_many :orders
  ### ensure 1-1 for address -> customer (address can have one customer)
  # validates_presence_of :customer_id
  # validates_presence_of :state
  ### must have recipient, primary street address, zip
  validates_presence_of :recipient, :street_1, :zip
  ### the below code sourced from PATS
  validates_format_of :zip, with: /\A\d{5}\z/, message: "should be five digits long"
  validates_inclusion_of :state, in: %w[PA WV], message: "must be in PA or WV"
  ### custom validations:
  ### check that zip truly is in PA / WV with custom validation below
  # validate :zip_in_pa_or_wv
  validate :customer_is_active
  validate :unique_address, on: :create
  # copilot wrote the below
  # validate :billing_cannot_become_shipping, if: :persisted?
  # validate :billing_must_remain_active, if: :persisted?
  before_save :convert_existing_billing_to_shipping

  ### add callbacks to check that only one building address after CRUD operations
    ### criteria 6: if new billing created, convert existing to shipping
  # before_create :ensure_billing_address_conversion, if: :is_billing
    ### criteria 5: ensure at least one billing address per customer
  # before_destroy :ensure_one_billing_address 
  validate :ensure_one_billing_address

  ### add scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where.not(active: true) }
  scope :by_recipient, -> { order('recipient') }
  scope :by_customer, -> { joins(:customer).order('customers.last_name, customers.first_name') }
  scope :shipping, -> { where.not(is_billing: true) }
  scope :billing, -> { where(is_billing: true) }
  ### consulted medicine.rb in PATS for the below; returns results filtered by customer
  ###scope :filter_by_customer, -> (customer_id) { where('addresses.customer_id = ?', customer_id)}

  ### additional methods: public
  def already_exists?
    Address.where(customer_id: customer_id, recipient: recipient, zip: zip).exists?
  end

  def make_active
    self.update_column(:active, true)
  end

  def make_inactive
    self.update_column(:active, false)
  end

  ### callback methods: private (bc client callback access is very very naughty)
  private
  # def zip_in_pa_or_wv
  #   ### convert zip (str) to (int), then compare if in range
  #   zip_int = zip.to_i
  #   pa_min, pa_max = 15001, 19612
  #   wv_min, wv_max = 24701, 26886
  #   ### unless (...) errors.add(...) structure sourced from PATS
  #   unless (zip_int >= pa_min && zip_int <= pa_max) || (zip_int >= wv_min && zip_int <= wv_max)
  #     errors.add(:zip, "must be a valid PA or WV zip code")
  #   end
  # end

  def customer_is_active
    unless !customer.nil? && customer.active # unless active and non-null, throw error
      errors.add(:customer, "customer must be active")
    end
  end

  def unique_address
    return true if self.zip.nil? || self.customer_id.nil? || self.recipient.nil?
    # if Address.already_exists?(customer_id, recipient, street_1, zip)
    if already_exists?
      errors.add(:base, "Duplicate address already exists for this customer")
    end
  end

  # def ensure_billing_address_conversion
  #   # copilot helped here --> finds billing address and updates attribute to false
  #   Address.where(customer_id: customer_id, is_billing: true).update_all(is_billing: false)
  # end

  def ensure_one_billing_address
    ### test edge cases first
    ### test nil customer
    return true if self.customer.nil?
    ### test at least one billing
    return true if self.is_billing && self.active
    ### check if there's only one remaining address and it is non-billing 
    if self.customer.addresses.billing.active - [self] == []# && !self.active
      errors.add(:address, "cannot have only address as shipping; billing must be added first")
    end
    # if is_billing && customer.addresses.billing.count == 1 # if only one billing address, prevent delete
    #   errors.add(:base, "Cannot delete the last billing address")
    #   throw :abort
    # end
  end

  # copilot wrote the below
  # def billing_cannot_become_shipping
  #   if saved_change_to_is_billing? && !is_billing
  #     errors.add(:is_billing, "Billing address cannot be converted to shipping")
  #   end
  # end

  # def billing_must_remain_active
  #   if is_billing? && saved_change_to_active? && !active
  #     errors.add(:active, "Billing address cannot be made inactive")
  #   end
  # end

  def convert_existing_billing_to_shipping
    if self.is_billing && self.active && !self.customer.billing_address.nil?
      self.customer.billing_address.update_column(:is_billing, false)
    end
  end

end