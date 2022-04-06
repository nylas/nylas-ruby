# frozen_string_literal: true

module Nylas
  # Additional methods for some of Calendar's other functionality
  # @see https://developer.nylas.com/docs/connectivity/calendar
  class JobStatusCollection < Collection
    def find_model(id)
      response = api.execute(
        **to_be_executed.merge(
          path: "#{resources_path}/#{id}",
          query: view_query
        )
      )

      object_type = response[:object]
      return OutboxJobStatus.from_hash(response, api: api) if object_type == "message"

      model.from_hash(response, api: api)
    end
  end
end
