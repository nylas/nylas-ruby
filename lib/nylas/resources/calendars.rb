# frozen_string_literal: true

require_relative "base_resource"
require_relative "../handler/api_operations"

module Nylas
  class Calendars < BaseResource
    include Operations::Get
    include Operations::Post
    include Operations::Put
    include Operations::Delete

    def initialize(sdk_instance)
      super("calendars", sdk_instance)
    end

    def get_availability(path_params: {}, request_body: nil)
      post(
        "#{host}/grants/#{path_params[:grant_id]}/calendars/availability",
        request_body: request_body
      )
    end

    def create(query_params: {}, request_body: nil)
      post(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params,
        request_body: request_body
      )
    end

    def find(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )
    end

    def list(path_params: {}, query_params: {})
      get(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params
      )
    end

    def update(path_params: {}, query_params: {}, request_body: nil)
      put(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params,
        request_body: request_body
      )
    end

    def destroy(path_params: {}, query_params: {})
      delete(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )
    end
  end
end
