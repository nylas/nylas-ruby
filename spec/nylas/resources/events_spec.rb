# frozen_string_literal: true

describe Nylas::Events do
  let(:events) { described_class.new(client) }
  let(:response) do
    [{
      busy: true,
      calendar_id: "7d93zl2palhxqdy6e5qinsakt",
      conferencing: {
        provider: "Zoom Meeting",
        details: {
          meeting_code: "code-123456",
          password: "password-123456",
          url: "https://zoom.us/j/1234567890?pwd=1234567890"
        }
      },
      created_at: 1661874192,
      description: "Description of my new calendar",
      hide_participants: false,
      grant_id: "41009df5-bf11-4c97-aa18-b285b5f2e386",
      html_link: "https://www.google.com/calendar/event?eid=bTMzcGJrNW4yYjk4bjk3OWE4Ef3feD2VuM29fMjAyMjA2MjdUMjIwMDAwWiBoYWxsYUBueWxhcy5jb20",
      id: "5d3qmne77v32r8l4phyuksl2x",
      location: "Roller Rink",
      metadata: { foo: "your_value" },
      object: "event",
      organizer: { email: "organizer@example.com", name: "" },
      participants: [
        {
          comment: "Aristotle",
          email: "aristotle@example.com",
          name: "Aristotle",
          phone_number: "+1 23456778",
          status: "maybe"
        }
      ],
      read_only: false,
      reminders: {
        use_default: false,
        overrides: [{ reminder_minutes: 10, reminder_method: "email" }]
      },
      recurrence: %w[RRULE:FREQ=WEEKLY;BYDAY=MO EXDATE:20211011T000000Z],
      status: "confirmed",
      title: "Birthday Party",
      updated_at: 1661874192,
      visibility: "private",
      when: {
        start_time: 1661874192,
        end_time: 1661877792,
        start_timezone: "America/New_York",
        end_timezone: "America/New_York",
        object: "timespan"
      }
    }, "mock_request_id"]
  end

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      query_params = { calendar_id: "5d3qmne77v32r8l4phyuksl2x" }
      path = "#{api_uri}/v3/grants/#{identifier}/events"
      allow(events).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      events_response = events.list(identifier: identifier, query_params: query_params)

      expect(events_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      identifier = "abc-123-grant-id"
      event_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { calendar_id: "5d3qmne77v32r8l4phyuksl2x" }
      path = "#{api_uri}/v3/grants/#{identifier}/events/#{event_id}"
      allow(events).to receive(:get)
        .with(path: path, query_params: query_params)
        .and_return(response)

      event_response = events.find(identifier: identifier, event_id: event_id, query_params: query_params)

      expect(event_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      identifier = "abc-123-grant-id"
      query_params = { calendar_id: "5d3qmne77v32r8l4phyuksl2x" }
      request_body = {
        when: {
          start_time: 1661874192,
          end_time: 1661877792,
          start_timezone: "America/New_York",
          end_timezone: "America/New_York"
        },
        description: "Description of my new event",
        location: "Los Angeles, CA",
        metadata: { foo: "value" }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/events"
      allow(events).to receive(:post)
        .with(path: path, request_body: request_body, query_params: query_params)
        .and_return(response)

      event_response = events.create(identifier: identifier, request_body: request_body,
                                     query_params: query_params)

      expect(event_response).to eq(response)
    end

    it "calls the post method with notetaker settings" do
      identifier = "abc-123-grant-id"
      query_params = { calendar_id: "5d3qmne77v32r8l4phyuksl2x" }
      request_body = {
        when: {
          start_time: 1661874192,
          end_time: 1661877792,
          start_timezone: "America/New_York",
          end_timezone: "America/New_York"
        },
        description: "Description of my new event",
        location: "Los Angeles, CA",
        metadata: { foo: "value" },
        notetaker: {
          id: "notetaker-123",
          name: "Custom Notetaker",
          meeting_settings: {
            video_recording: true,
            audio_recording: true,
            transcription: true
          }
        }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/events"
      allow(events).to receive(:post)
        .with(path: path, request_body: request_body, query_params: query_params)
        .and_return(response)

      event_response = events.create(identifier: identifier, request_body: request_body,
                                     query_params: query_params)

      expect(event_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      identifier = "abc-123-grant-id"
      event_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { calendar_id: "5d3qmne77v32r8l4phyuksl2x" }
      request_body = {
        when: {
          start_time: 1661874192,
          end_time: 1661877792,
          start_timezone: "America/New_York",
          end_timezone: "America/New_York"
        },
        description: "Description of my new event",
        location: "Los Angeles, CA",
        metadata: { foo: "value" }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/events/#{event_id}"
      allow(events).to receive(:put)
        .with(path: path, request_body: request_body, query_params: query_params)
        .and_return(response)

      event_response = events.update(identifier: identifier, event_id: event_id,
                                     request_body: request_body, query_params: query_params)

      expect(event_response).to eq(response)
    end

    it "calls the put method with notetaker settings" do
      identifier = "abc-123-grant-id"
      event_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { calendar_id: "5d3qmne77v32r8l4phyuksl2x" }
      request_body = {
        description: "Updated event with notetaker",
        notetaker: {
          id: "notetaker-456",
          name: "Updated Notetaker",
          meeting_settings: {
            video_recording: false,
            audio_recording: true,
            transcription: true
          }
        }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/events/#{event_id}"
      allow(events).to receive(:put)
        .with(path: path, request_body: request_body, query_params: query_params)
        .and_return(response)

      event_response = events.update(identifier: identifier, event_id: event_id,
                                     request_body: request_body, query_params: query_params)

      expect(event_response).to eq(response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      identifier = "abc-123-grant-id"
      event_id = "5d3qmne77v32r8l4phyuksl2x"
      query_params = { calendar_id: "5d3qmne77v32r8l4phyuksl2x" }
      path = "#{api_uri}/v3/grants/#{identifier}/events/#{event_id}"
      allow(events).to receive(:delete)
        .with(path: path, query_params: query_params)
        .and_return([true, response[1]])

      event_response = events.destroy(identifier: identifier, event_id: event_id, query_params: query_params)

      expect(event_response).to eq([true, response[1]])
    end
  end

  describe "#send_rsvp" do
    it "calls the post method with the correct parameters" do
      identifier = "abc-123-grant-id"
      event_id = "5d3qmne77v32r8l4phyuksl2x"
      request_body = { status: "yes" }
      query_params = { calendar_id: "5d3qmne77v32r8l4phyuksl2x" }
      path = "#{api_uri}/v3/grants/#{identifier}/events/#{event_id}/send-rsvp"

      allow(events).to receive(:post)
        .with(path: path, request_body: request_body, query_params: query_params)

      events.send_rsvp(identifier: identifier, event_id: event_id, request_body: request_body,
                       query_params: query_params)
    end
  end

  describe "#events_import" do
    let(:identifier) { "grant-123" }
    let(:query_params) { { calendar_id: "cal-123", start_time: 1234567890, end_time: 1234599999 } }

    it "calls get_list with the correct parameters" do
      allow(events).to receive(:get_list)
        .with(
          path: "#{api_uri}/v3/grants/#{identifier}/events/import",
          query_params: query_params
        )
        .and_return([[], "request-id", "next-cursor"])

      result = events.list_import_events(identifier: identifier, query_params: query_params)
      expect(result).to eq([[], "request-id", "next-cursor"])
    end

    it "returns events, request_id and cursor" do
      expected_response = [
        [{ "id" => "event-123", "title" => "Test Event" }],
        "request-id-abc",
        "next-cursor-xyz"
      ]

      allow(events).to receive(:get_list).and_return(expected_response)

      response = events.list_import_events(identifier: identifier, query_params: query_params)

      expect(response).to eq(expected_response)
      expect(response[0]).to be_an(Array)
      expect(response[1]).to be_a(String)
      expect(response[2]).to be_a(String)
    end
  end
end
