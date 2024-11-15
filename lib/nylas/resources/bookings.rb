# frozen_string_literal: true

require_relative "resource"
require_relative "../handler/api_operations"

module Nylas
  # Nylas Messages API
  class Bookings < Resource
    include ApiOperations::Get
    include ApiOperations::Post
    include ApiOperations::Put
    include ApiOperations::Delete
    include ApiOperations::Patch

    # Return a booking.
    # @param booking_id [String] The id of the booking to return.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Hash, String)] The booking and API request ID.
    def find(booking_id:, query_params: nil)
      get(
        path: "#{api_uri}/v3/scheduling/bookings/#{booking_id}",
        query_params: query_params
      )
    end

    # Create a booking.
    # @param request_body [Hash] The values to create the booking with.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Hash, String)] The created booking and API Request ID.
    def create(request_body:, query_params: nil)
      post(
        path: "#{api_uri}/v3/scheduling/bookings",
        request_body: request_body,
        query_params: query_params
      )
    end

    # Create a booking.
    # @param request_body [Hash] The values to update the booking with.
    # @param booking_id [String] The id of the booking to update.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Hash, String)] The created booking and API Request ID.
    def update(request_body:, booking_id:, query_params: nil)
      patch(
        path: "#{api_uri}/v3/scheduling/bookings/#{booking_id}",
        request_body: request_body,
        query_params: query_params
      )
    end

    # Confirm a booking.
    # @param booking_id [String] The id of the booking to confirm.
    # @param request_body [Hash] The values to update the booking with
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(Hash, String)] The updated booking and API Request ID.
    def confirm(booking_id:, request_body:, query_params: nil)
      put(
        path: "#{api_uri}/v3/scheduling/bookings/#{booking_id}",
        request_body: request_body,
        query_params: query_params
      )
    end

    # Delete a booking.
    # @param booking_id [String] The id of the booking to delete.
    # @param query_params [Hash, nil] Query params to pass to the request.
    # @return [Array(TrueClass, String)] True and the API Request ID for the delete operation.
    def destroy(booking_id:, query_params: nil)
      _, request_id = delete(
        path: "#{api_uri}/v3/scheduling/bookings/#{booking_id}",
        query_params: query_params
      )

      [true, request_id]
    end
  end
end
