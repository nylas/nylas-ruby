# frozen_string_literal: true

describe NylasV2::Calendars do
  let(:calendars) { described_class.new(client) }
  let(:response) do
    [{
      grant_id: "abc-123-grant-id",
      description: "Description of my new calendar",
      hex_color: "#039BE5",
      hex_foreground_color: "#039BE5",
      id: "5d3qmne77v32r8l4phyuksl2x",
      is_owned_by_user: true,
      is_primary: true,
      location: "Los Angeles, CA",
      metadata: { foo: "value" },
      name: "My New Calendar",
      object: "calendar",
      read_only: false,
      timezone: "America/Los_Angeles"
    }, "mock_request_id"]
  end

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      path = "#{api_uri}/v3/grants/#{identifier}/calendars"
      allow(calendars).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      calendars_response = calendars.list(identifier: identifier, query_params: nil)

      expect(calendars_response).to eq(list_response)
    end

    it "calls the get method with the correct parameters and query params" do
      identifier = "abc-123-grant-id"
      query_params = { foo: "bar" }
      path = "#{api_uri}/v3/grants/#{identifier}/calendars"
      allow(calendars).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      calendars_response = calendars.list(identifier: identifier, query_params: query_params)

      expect(calendars_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      calendar_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/calendars/#{calendar_id}"
      allow(calendars).to receive(:get)
        .with(path: path)
        .and_return(response)

      calendar_response = calendars.find(identifier: identifier, calendar_id: calendar_id)

      expect(calendar_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      identifier = "abc-123-grant-id"
      request_body = {
        name: "My New Calendar",
        description: "Description of my new calendar",
        location: "Los Angeles, CA",
        timezone: "America/Los_Angeles",
        metadata: { foo: "value" }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/calendars"
      allow(calendars).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      calendar_response = calendars.create(identifier: identifier, request_body: request_body)

      expect(calendar_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      identifier = "abc-123-grant-id"
      calendar_id = "5d3qmne77v32r8l4phyuksl2x"
      request_body = {
        name: "My New Calendar",
        description: "Description of my new calendar",
        location: "Los Angeles, CA",
        timezone: "America/Los_Angeles",
        metadata: { foo: "value" }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/calendars/#{calendar_id}"
      allow(calendars).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(response)

      calendar_response = calendars.update(identifier: identifier, calendar_id: calendar_id,
                                           request_body: request_body)

      expect(calendar_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      identifier = "abc-123-grant-id"
      calendar_id = "5d3qmne77v32r8l4phyuksl2x"
      path = "#{api_uri}/v3/grants/#{identifier}/calendars/#{calendar_id}"
      allow(calendars).to receive(:delete)
        .with(path: path)
        .and_return([true, response[1]])

      calendar_response = calendars.destroy(identifier: identifier, calendar_id: calendar_id)

      expect(calendar_response).to eq([true, response[1]])
    end
  end

  describe "#get_availability" do
    it "calls the post method with the correct parameters" do
      request_body = {
        start_time: 1614556800,
        end_time: 1614643200,
        participants: [
          {
            email: "test@gmail.com",
            calendar_ids: ["calendar-123"],
            open_hours: [
              {
                days: [0],
                timezone: "America/Los_Angeles",
                start: "09:00",
                end: "17:00",
                exdates: ["2021-03-01"]
              }
            ]
          }
        ],
        duration_minutes: 60,
        interval_minutes: 30,
        round_to_30_minutes: true,
        availability_rules: {
          availability_method: "max-availability",
          buffer: { before: 10, after: 10 },
          default_open_hours: [
            {
              days: [0],
              timezone: "America/Los_Angeles",
              start: "09:00",
              end: "17:00",
              exdates: ["2021-03-01"]
            }
          ],
          round_robin_event_id: "event-123"
        }
      }
      path = "#{api_uri}/v3/calendars/availability"

      allow(calendars).to receive(:post)
        .with(path: path, request_body: request_body)

      calendars.get_availability(request_body: request_body)
    end
  end

  describe "#get_free_busy" do
    it "calls the post method with the correct parameters" do
      identifier = "abc-123-grant-id"
      request_body = {
        start_time: 1614556800,
        end_time: 1614643200,
        emails: ["test@gmail.com"]
      }

      allow(calendars).to receive(:post)
        .with(path: "#{api_uri}/v3/grants/#{identifier}/calendars/free-busy", request_body: request_body)

      calendars.get_free_busy(identifier: identifier, request_body: request_body)
    end
  end
end
