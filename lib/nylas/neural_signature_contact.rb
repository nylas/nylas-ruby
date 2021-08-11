# frozen_string_literal: true

module Nylas
  # Structure to represent the Neural API's Signature Extraction Contact object
  # @see https://developer.nylas.com/docs/intelligence/signature-extraction/#parse-signature-response
  class NeuralSignatureContact
    include Model::Attributable
    has_n_of_attribute :job_titles, :string
    has_n_of_attribute :links, :neural_contact_link
    has_n_of_attribute :phone_numbers, :string
    has_n_of_attribute :emails, :string
    has_n_of_attribute :names, :neural_contact_name

    attr_accessor :api

    # Creates a Nylas contact object compatible with the contact endpoints.
    # Please note if multiple names or multiple job titles were parsed only
    # the first set are used.
    def to_contact_object
      contact = merge_multiple_hashes([convert_names, convert_emails, convert_phone_numbers, convert_links])
      contact[:job_title] = job_titles[0] unless job_titles.nil?
      Contact.new(**contact.merge(api: api))
    end

    private

    def convert_names
      return if names.nil?

      contact = {}
      contact[:given_name] = names[0].first_name if names[0].first_name
      contact[:surname] = names[0].last_name if names[0].last_name
      contact
    end

    def convert_emails
      return if emails.nil?

      contact = {}
      contact[:emails] = []
      emails.each do |e|
        contact[:emails].push(type: "personal", email: e)
      end
      contact
    end

    def convert_phone_numbers
      return if phone_numbers.nil?

      contact = {}
      contact[:phone_numbers] = []
      phone_numbers.each do |number|
        contact[:phone_numbers].push(type: "mobile", number: number)
      end
      contact
    end

    def convert_links
      return if links.nil?

      contact = {}
      contact[:web_pages] = []
      links.each do |link|
        type = "homepage"
        type = link.description unless link.description.empty?
        contact[:web_pages].push(type: type, url: link.url)
      end
      contact
    end

    # For Ruby 2.5 support as it doesn't support multiple hashes to merge at once
    def merge_multiple_hashes(hashes_to_merge)
      hash = {}
      hashes_to_merge.each do |new_hash|
        hash = hash.merge(new_hash)
      end

      hash
    end
  end
end
