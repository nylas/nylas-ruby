# frozen_string_literal: true

require_relative "http_client"

module Nylas
  module Operations
    module Create
      include HttpClient

      def create(path_params: {}, query_params: {}, request_body: nil)
        path = "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}"

        post(path: path, query: query_params, payload: request_body, api_key: api_key)
      end
    end

    module Find
      include HttpClient

      def find(path_params, query_params: {})
        path = "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}"

        get(path: path, query: query_params, api_key: api_key)
      end
    end

    module List
      include HttpClient

      def list(path_params, query_params: {})
        path = "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}"

        get(path: path, query: query_params, api_key: api_key)
      end
    end

    module Update
      include HttpClient

      def update(path_params: {}, query_params: {}, request_body: nil)
        path = "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}"

        put(path: path, query: query_params, payload: request_body, api_key: api_key)
      end
    end

    module Destroy
      include HttpClient

      def destroy(path_params: {}, query_params: {}, request_body: nil)
        path = "#{host}/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}"

        delete(path: path, query: query_params, payload: request_body, api_key: api_key)
      end
    end
  end
end