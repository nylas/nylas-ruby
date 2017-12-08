module Nylas
  module V1
    # Represents the Contact object in Nylas for users who have not yet upgraded their API to V2
    class Contact
      include Model
      self.resources_path = "/contacts"
      self.searchable = false
      self.read_only = true


      attribute :id, :string
      attribute :object, :string, default: "contact"
      attribute :account_id, :string
      attribute :name, :string
      attribute :email, :string

      has_n_of_attribute :phone_numbers, :phone_number
    end
  end
end
