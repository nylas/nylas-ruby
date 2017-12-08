module Nylas
    class Contact
      include Model
      self.resources_path = "/contacts"

      attribute :id, :string, exclude_when: [:creating, :updating]
      attribute :object, :string, default: "contact"
      attribute :account_id, :string, exclude_when: [:creating, :updating]
      attribute :given_name, :string
      attribute :middle_name, :string
      attribute :surname, :string
      attribute :birthday, :nylas_date
      attribute :suffix, :string
      attribute :nickname, :string
      attribute :company_name, :string
      attribute :job_title, :string
      attribute :manager_name, :string
      attribute :office_location, :string
      attribute :notes, :string
      attribute :web_page, :web_page

      has_n_of_attribute :email_addresses, :email_address
      has_n_of_attribute :im_addresses, :im_address
      has_n_of_attribute :physical_addresses, :physical_address
      has_n_of_attribute :phone_numbers, :phone_number
      has_n_of_attribute :web_pages, :web_page
  end
end
