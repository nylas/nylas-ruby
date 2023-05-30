# frozen_string_literal: true

require_relative "base_resource"
require_relative "../operations/api_operations"

module Nylas
  # Grants
  class Grants < BaseResource
    include Operations::Create
    include Operations::Find
    include Operations::List
    include Operations::Update
    include Operations::Destroy

    def initialize(parent)
      super("grants", parent)
    end

    def create(query_params: {}, request_body: nil)
      i_create(
        "#{host}/grants",
        query_params: query_params,
        request_body: request_body
      )
    end

    def find(path_params: {}, query_params: {})
      i_find(
        "#{host}/grants/#{path_params[:grant_id]}",
        query_params: query_params
      )
    end

    def list(query_params: {})
      i_list(
        "#{host}/grants",
        query_params: query_params
      )
    end

    def update(path_params: {}, query_params: {}, request_body: nil)
      i_update(
        "#{host}/grants/#{path_params[:grant_id]}",
        query_params: query_params,
        request_body: request_body
      )
    end

    def destroy(path_params: {}, query_params: {})
      i_destroy(
        "#{host}/grants/#{path_params[:grant_id]}",
        query_params: query_params
      )
    end
  end
end
