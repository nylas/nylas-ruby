# frozen_string_literal: true

module Nylas
  # Structure to represent the Folder Schema
  # @see https://docs.nylas.com/reference#folders
  class Folder
    include Model
    self.resources_path = "/folders"
    self.creatable = true
    self.listable = true
    self.showable = true
    self.filterable = false
    self.updatable = true
    self.destroyable = true
    self.id_listable = true

    attribute :id, :string, read_only: true
    attribute :account_id, :string, read_only: true
    attribute :object, :string, read_only: true

    attribute :name, :string
    attribute :display_name, :string
    attribute :job_status_id, :string, read_only: true
  end
end
