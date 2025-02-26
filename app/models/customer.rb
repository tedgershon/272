class Customer < ApplicationRecord
  has_many :addresses
  has_many :orders

  ### must have first_name, last_name
  validates_presence_of :first_name, :last_name#, :phone, :email

  validates_format_of :phone, with: /\A(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})\z/, message: "should be 10 digits in any format"
  validates_format_of :email, with: /\A[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info))\z/i, message: "is not a valid format"

  ### add callback for stripping phone number input (do this before testing format)
  before_save :reformat_phone

  ### add scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :alphabetical, -> { order(:last_name, :first_name) }

  ### additional methods: public
  def name
    self.last_name + ", " + self.first_name
  end

  def proper_name
    self.first_name + " " + self.last_name
  end

  def make_active
    self.update_column(:active, true)
  end

  def make_inactive
    self.update_column(:active, false)
  end

  def billing_address
    self.addresses.billing.active.first
  end

  ### callback method
  private
  ### All the below code was sourced from PATS, specifically owner.rb file
  # We need to strip non-digits before saving to db
  def reformat_phone
    phone = self.phone.to_s  # change to string in case input as all numbers 
    phone.gsub!(/[^0-9]/,"") if phone.present? # strip all non-digits
    self.phone = phone       # reset self.phone to new string
  end
end