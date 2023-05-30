# frozen_string_literal: true

require_relative "base_resource"
require_relative "../operations/api_operations"

module Nylas
  class Calendars < BaseResource
    include Operations::Create
    include Operations::Find
    include Operations::List
    include Operations::Update
    include Operations::Destroy

    def initialize(sdk_instance)
      super("calendars", sdk_instance)
    end

    def get_availability(path_params: {}, request_body: nil)
      i_create(
        "#{host}/grants/#{path_params[:grant_id]}/calendars/availability",
        request_body: request_body
      )
    end

    def create(query_params: {}, request_body: nil)
      i_create(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params,
        request_body: request_body
      )
    end

    def find(path_params: {}, query_params: {})
      i_find(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )
    end

    def list(query_params: {})
      i_list(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}",
        query_params: query_params
      )
    end

    def update(path_params: {}, query_params: {}, request_body: nil)
      i_update(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params,
        request_body: request_body
      )
    end

    def destroy(path_params: {}, query_params: {})
      i_destroy(
        "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}",
        query_params: query_params
      )
    end
  end
end
