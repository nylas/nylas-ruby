# frozen_string_literal: true

module Nylas
  # Ruby representation of a the Nylas Scheduler API
  # @see https://developer.nylas.com/docs/api/scheduler/#overview
  class Scheduler
    include Model
    self.resources_path = "/manage/pages"
    allows_operations(creatable: true, listable: true, filterable: true, showable: true, updatable: true,
                      destroyable: true)

    attribute :id, :integer, read_only: true
    attribute :app_client_id, :string
    attribute :app_organization_id, :integer
    attribute :config, :scheduler_config
    attribute :edit_token, :string
    attribute :name, :string
    attribute :slug, :string
    attribute :created_at, :date
    attribute :modified_at, :date

    has_n_of_attribute :access_tokens, :string

    def get_available_calendars
      raise ArgumentError, "Cannot get calendars for a page without an ID." if id.nil?

      api.execute(
        method: :get,
        path: "/manage/pages/#{id}/calendars"
      )
    end

    def upload_image(content_type:, object_name:)
      raise ArgumentError, "Cannot upload an image to a page without an ID." if id.nil?

      payload = {
        contentType: content_type,
        objectName: object_name
      }
      api.execute(
        method: :put,
        path: "/manage/pages/#{id}/upload-image",
        payload: JSON.dump(payload)
      )
    end
  end
end
