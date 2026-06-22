# frozen_string_literal: true

describe Nylas::Bookings do
  let(:bookings) { described_class.new(client) }
  let(:response) do
    [{
      "event_id": "eventid123",
      "booking_id": "booking-123",
      "title": "My test event",
      "description": "test",
      "organizer": {
        "email": "scheduler-booking@nylas.com",
        "name": "Test"
      },
      "status": "booked"
    }, "mock_request_id"]
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      booking_id = "booking-123"
      path = "#{api_uri}/v3/scheduling/bookings/#{booking_id}"
      allow(bookings).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(response)

      bookings_response = bookings.find(booking_id: booking_id)

      expect(bookings_response).to eq(response)
    end

    it "calls the get method with the correct query params" do
      booking_id = "booking-123"
      query_params = { "foo": "bar" }
      path = "#{api_uri}/v3/scheduling/bookings/#{booking_id}"
      allow(bookings).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response)

      bookings_response = bookings.find(booking_id: booking_id, query_params: query_params)

      expect(bookings_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      request_body = {
        start_time: 1730194200,
        end_time: 1730196000,
        participants: [
          {
            email: "scheduler-booking@nylas.com"
          }
        ],
        guest: {
          name: "TEST",
          email: "test@nylas.com"
        }
      }
      path = "#{api_uri}/v3/scheduling/bookings"
      allow(bookings).to receive(:post)
        .with(path: path, request_body: request_body, query_params: nil)
        .and_return(response)

      bookings_response = bookings.create(request_body: request_body)

      expect(bookings_response).to eq(response)
    end

    it "calls the post method with the correct query parameters" do
      request_body = {
        start_time: 1730194200,
        end_time: 1730196000,
        participants: [
          {
            email: "scheduler-booking@nylas.com"
          }
        ],
        guest: {
          name: "TEST",
          email: "test@nylas.com"
        }
      }
      query_params = { "foo": "bar" }
      path = "#{api_uri}/v3/scheduling/bookings"
      allow(bookings).to receive(:post)
        .with(path: path, request_body: request_body, query_params: query_params)
        .and_return(response)

      bookings_response = bookings.create(request_body: request_body, query_params: query_params)

      expect(bookings_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the patch method with the correct parameters" do
      booking_id = "booking-123"
      request_body = {
        start_time: 1730194200,
        end_time: 1730196000
      }
      path = "#{api_uri}/v3/scheduling/bookings/#{booking_id}"
      allow(bookings).to receive(:patch)
        .with(path: path, request_body: request_body, query_params: nil)
        .and_return(response)

      bookings_response = bookings.update(
        request_body: request_body,
        booking_id: booking_id
      )

      expect(bookings_response).to eq(response)
    end

    it "calls the patch method with the correct query parameters" do
      booking_id = "booking-123"
      query_params = { "foo": "bar" }
      request_body = {
        start_time: 1730194200,
        end_time: 1730196000
      }
      path = "#{api_uri}/v3/scheduling/bookings/#{booking_id}"
      allow(bookings).to receive(:patch)
        .with(path: path, request_body: request_body, query_params: query_params)
        .and_return(response)

      bookings_response = bookings.update(
        request_body: request_body,
        booking_id: booking_id,
        query_params: query_params
      )

      expect(bookings_response).to eq(response)
    end
  end

  describe "#confirm" do
    it "calls the put method with the correct parameters" do
      booking_id = "booking-123"
      request_body = {
        salt: "_salt",
        status: "cancelled"
      }
      path = "#{api_uri}/v3/scheduling/bookings/#{booking_id}"
      allow(bookings).to receive(:put)
        .with(path: path, request_body: request_body, query_params: nil)
        .and_return(response)

      bookings_response = bookings.confirm(
        booking_id: booking_id,
        request_body: request_body
      )

      expect(bookings_response).to eq(response)
    end

    it "calls the put method with the correct query parameters" do
      booking_id = "booking-123"
      query_params = { "foo": "bar" }
      request_body = {
        salt: "_salt",
        status: "cancelled"
      }
      path = "#{api_uri}/v3/scheduling/bookings/#{booking_id}"
      allow(bookings).to receive(:put)
        .with(path: path, request_body: request_body, query_params: query_params)
        .and_return(response)

      bookings_response = bookings.confirm(
        booking_id: booking_id,
        request_body: request_body,
        query_params: query_params
      )

      expect(bookings_response).to eq(response)
    end
  end

  describe "#destroy" do
    let(:delete_response) { [true, "mock_request_id"] }

    it "calls the delete method with the correct parameters" do
      booking_id = "booking-123"
      path = "#{api_uri}/v3/scheduling/bookings/#{booking_id}"
      allow(bookings).to receive(:delete)
        .with(path: path, query_params: nil, request_body: nil)
        .and_return(delete_response)

      bookings_response = bookings.destroy(booking_id: booking_id)
      expect(bookings_response).to eq(delete_response)
    end

    it "calls the delete method with the correct query parameters" do
      booking_id = "booking-123"
      query_params = { "foo": "bar" }
      path = "#{api_uri}/v3/scheduling/bookings/#{booking_id}"
      allow(bookings).to receive(:delete)
        .with(path: path, query_params: query_params, request_body: nil)
        .and_return(delete_response)

      bookings_response = bookings.destroy(booking_id: booking_id, query_params: query_params)
      expect(bookings_response).to eq(delete_response)
    end

    it "calls the delete method with request_body for cancellation_reason" do
      booking_id = "booking-123"
      request_body = { cancellation_reason: "Meeting no longer needed" }
      path = "#{api_uri}/v3/scheduling/bookings/#{booking_id}"
      allow(bookings).to receive(:delete)
        .with(path: path, query_params: nil, request_body: request_body)
        .and_return(delete_response)

      bookings_response = bookings.destroy(
        booking_id: booking_id,
        request_body: request_body
      )
      expect(bookings_response).to eq(delete_response)
    end
  end
end
