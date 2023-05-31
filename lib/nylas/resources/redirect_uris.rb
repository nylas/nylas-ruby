# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"
# require other mixins as needed

module Nylas
  # redirect uris
  class RedirectURIs < BaseResource
    include Operations::Get
    include Operations::Post
    include Operations::Put
    include Operations::Delete

    def initialize(sdk_instance)
      super("redirect-uris", sdk_instance)
    end

    def create(request_body: nil)
      post(
        "#{host}/applications/#{resource_name}",
        request_body: request_body
      )
    end

    def find(path_params: {})
      get(
        "#{host}/applications/#{resource_name}/#{path_params[:id]}"
      )
    end

    def list
      get("#{host}/applications/#{resource_name}")
    end

    def update(path_params: {}, request_body: nil)
      put(
        "#{host}/applications/#{resource_name}/#{path_params[:id]}",
        request_body: request_body
      )
    end

    def destroy(path_params: {})
      delete(
        "#{host}/applications/#{resource_name}/#{path_params[:id]}"
      )
    end
  end
end
