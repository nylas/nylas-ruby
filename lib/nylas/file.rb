# frozen_string_literal: true

module Nylas
  # Structure to represent a the File Schema.
  # @see https://docs.nylas.com/reference#events
  class File
    include Model
    self.resources_path = "/files"
    allows_operations(listable: true, showable: true, filterable: true, creatable: true)

    attribute :id, :string
    attribute :account_id, :string
    attribute :content_id, :string
    has_n_of_attribute :message_ids, :string

    attribute :object, :string

    attribute :content_type, :string
    attribute :filename, :string
    attribute :size, :integer

    attr_accessor :file
    # Downloads and caches a local copy of the file.
    # @return [Tempfile] - Local copy of the file
    def download
      return file if file

      self.file = retrieve_file
    end

    # Redownloads a file even if it's been cached. Closes and unlinks the tempfile to help memory usage.
    def download!
      return download if file.nil?

      file.close
      file.unlink
      self.file = nil
      download
    end

    def create
      save
    end

    def save
      raise ModelNotUpdatableError if persisted?

      response = api.execute(path: "/files", method: :post, headers: { multipart: true },
                             payload: { file: file })
      attributes.merge(response.first)
      true
    end

    private

    def retrieve_file
      response = api.get(path: "#{resource_path}/download")
      filename = response.headers.fetch(:content_disposition, "").gsub("attachment; filename=", "")
      temp_file = Tempfile.new(filename, encoding: "ascii-8bit")
      temp_file.write(response.body)
      temp_file.seek(0)
      temp_file
    end
  end
end
