# frozen_string_literal: true

module Nylas
  module Operations
    module Create
      def create(path_params: {}, query_params: {}, request_body: nil)
        path = "#{host}/v3/grants/#{path_params[:grant_id]}/#{resource_name}"

        post(path: path, query: query_params, payload: request_body, api_key: api_key)
      end
    end

    module Find
      def find(path_params, query_params)
        path = "#{host}/v3/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}"

        get(path: path, query: query_params, api_key: api_key)
      end
    end

    module List
      def list(path_params, query_params)
        path = URI("#{host}/v3/grants/#{path_params[:grant_id]}/#{resource_name}")

        get(path: path, query: query_params, api_key: api_key)
      end
    end

    module Update
      def update(path_params: {}, query_params: {}, request_body: nil)
        path = "#{host}/v3/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}"

        put(path: path, query: query_params, payload: request_body, api_key: api_key)
      end
    end

    module Destroy
      def destroy(path_params: {}, query_params: {}, request_body: nil)
        path = "#{host}/v3/grants/#{path_params[:grant_id]}/#{resource_name}/#{path_params[:id]}"

        delete(path: path, query: query_params, payload: request_body, api_key: api_key)
      end
    end
  end
end
