# frozen_string_literal: true

module Nylas
  # ActiveModel compliant interface for interacting with the Contacts API
  # @see https://docs.nylas.com/reference#contacts
  class Contact
    include Model
    self.resources_path = "/contacts"
    self.creatable = true
    self.listable = true
    self.showable = true
    self.filterable = true
    self.updatable = true
    self.destroyable = true

    attribute :id, :string, read_only: true
    attribute :object, :string, default: "contact"
    attribute :account_id, :string, read_only: true

    attribute :given_name, :string
    attribute :middle_name, :string
    attribute :picture_url, :string
    attribute :surname, :string
    attribute :birthday, :string
    attribute :suffix, :string
    attribute :nickname, :string
    attribute :company_name, :string
    attribute :job_title, :string
    attribute :manager_name, :string
    attribute :office_location, :string
    attribute :notes, :string
    attribute :source, :string
    attribute :job_status_id, :string, read_only: true

    has_n_of_attribute :groups, :contact_group
    has_n_of_attribute :emails, :email_address
    has_n_of_attribute :im_addresses, :im_address
    has_n_of_attribute :physical_addresses, :physical_address
    has_n_of_attribute :phone_numbers, :phone_number
    has_n_of_attribute :web_pages, :web_page

    # @returns [Tempfile] path to the retrieved picture. It is preferrable to cache this in your system than
    # to retrieve it from nylas every time.
    def picture
      return @picture_tempfile if @picture_tempfile

      @picture_tempfile = Tempfile.new
      @picture_tempfile.write(api.get(path: "#{resource_path}/picture"))
      @picture_tempfile.close
      @picture_tempfile
    end
  end
end
