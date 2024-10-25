# frozen_string_literal: true

describe Nylas::Configurations do
  let(:configurations) { described_class.new(client) }
  let(:response) do
    [{
      "id": "configuration-123",
      "slug": nil,
      "participants": [
        {
          "email": "nylas-scheduler-1@gmail.com",
          "is_organizer": true,
          "name": "Nylas Scheduler",
          "availability": {
            "calendar_ids": [
              "primary"
            ]
          },
          "booking": {
            "calendar_id": "nylas-scheduler-1@gmail.com"
          },
          "timezone": "Europe/Amsterdam"
        }
      ],
      "requires_session_auth": false,
      "availability": {
        "duration_minutes": 30,
        "interval_minutes": 30,
        "availability_rules": {
          "availability_method": "collective",
          "buffer": {
            "before": 0,
            "after": 0
          },
          "default_open_hours": [
            {
              "days": [
                0,
                1,
                2,
                3,
                4,
                5,
                6
              ],
              "exdates": nil,
              "timezone": "Europe/Amsterdam",
              "start": "00:15",
              "end": "23:45"
            }
          ],
          "round_robin_group_id": ""
        }
      },
      "event_booking": {
        "title": "SDK - test",
        "timezone": "Europe/Amsterdam",
        "description": "",
        "location": "",
        "booking_type": "booking",
        "conferencing": {},
        "hide_participants": nil,
        "disable_emails": nil
      },
      "scheduler": {
        "available_days_in_future": 30,
        "min_cancellation_notice": 0,
        "min_booking_notice": 60,
        "confirmation_redirect_url": "",
        "hide_rescheduling_options": false,
        "hide_cancellation_options": false,
        "hide_additional_guests": false,
        "cancellation_policy": "",
        "email_template": {
          "booking_confirmed": {}
        }
      },
      "appearance": nil
    },
     {
       "id": "configuration-456",
       "slug": nil,
       "participants": [
         {
           "email": "nylas-scheduler-1@gmail.com",
           "is_organizer": true,
           "name": "Nylas Scheduler",
           "availability": {
             "calendar_ids": [
               "primary"
             ]
           },
           "booking": {
             "calendar_id": "nylas-scheduler-1@gmail.com"
           },
           "timezone": "Europe/Amsterdam"
         }
       ],
       "requires_session_auth": false,
       "availability": {
         "duration_minutes": 30,
         "availability_rules": {
           "availability_method": "collective",
           "buffer": {
             "before": 0,
             "after": 0
           },
           "default_open_hours": [
             {
               "days": [
                 1,
                 2,
                 3,
                 4,
                 5
               ],
               "exdates": nil,
               "timezone": "Europe/Amsterdam",
               "start": "06:00",
               "end": "23:00"
             }
           ],
           "round_robin_group_id": ""
         }
       },
       "event_booking": {
         "title": "test - 2",
         "timezone": "Europe/Amsterdam",
         "description": "",
         "location": "",
         "booking_type": "booking",
         "conferencing": {},
         "hide_participants": nil,
         "disable_emails": nil
       },
       "scheduler": {
         "available_days_in_future": 30,
         "min_cancellation_notice": 0,
         "min_booking_notice": 60,
         "hide_rescheduling_options": false,
         "hide_cancellation_options": false,
         "hide_additional_guests": false,
         "cancellation_policy": "",
         "email_template": {
           "booking_confirmed": {}
         }
       },
       "appearance": nil
     }]
  end

  describe "#list" do
    let(:list_response) do
      response
    end

    it "calls the get method with the correct parameters" do
      identifier = "grant-123"
      path = "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations"
      allow(configurations).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      configurations_response = configurations.list(identifier: identifier, query_params: nil)
      expect(configurations_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      identifier = "grant-123"
      configuration_id = "configuration-123"
      path = "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations/#{configuration_id}"
      allow(configurations).to receive(:get)
        .with(path: path)
        .and_return(response[0])

      configuration_response = configurations.find(identifier: identifier, configuration_id: configuration_id)
      expect(configuration_response).to eq(response[0])
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      identifier = "grant-123"
      request_body = {
        "requires_session_auth": false,
        "participants": [
          {
            name: "Test",
            email: "nylas-scheduler-1@gmail.com",
            is_organizer: true,
            availability: {
              calendar_ids: [
                "primary"
              ]
            },
            booking: {
              calendar_id: "primary"
            }
          }
        ],
        availability: {
          duration_minutes: 30
        },
        event_booking: {
          title: "My test event"
        }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations"
      allow(configurations).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response[0])

      configuration_response = configurations.create(identifier: identifier, request_body: request_body)

      expect(configuration_response).to eq(response[0])
    end
  end

  describe "#update" do
    let(:update_response) do
      updated_data = response[0].dup
      updated_data[:event_booking][:title] = "Updated Title"
      updated_data
    end

    it "calls the put method with the correct parameters" do
      identifier = "grant-123"
      configuration_id = "configuration-123"
      request_body = {
        event_booking: {
          title: "Updated Title"
        }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations/#{configuration_id}"
      allow(configurations).to receive(:put)
        .with(path: path, request_body: request_body)
        .and_return(update_response)

      configuration_response = configurations.update(
        identifier: identifier,
        configuration_id: configuration_id, request_body: request_body
      )

      expect(configuration_response).to eq(update_response)
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      identifier = "grant-123"
      configuration_id = "configuration-123"
      path = "#{api_uri}/v3/grants/#{identifier}/scheduling/configurations/#{configuration_id}"
      allow(configurations).to receive(:delete)
        .with(path: path)
        .and_return([true, "request-id-123"])

      configuration_response = configurations.destroy(identifier: identifier,
                                                      configuration_id: configuration_id)

      expect(configuration_response).to eq([true, "request-id-123"])
    end
  end
end
