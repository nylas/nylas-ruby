# frozen_string_literal: true

describe Nylas::Notetakers do
  let(:notetakers) { described_class.new(client) }
  let(:response) do
    [{
      id: "note123",
      grant_id: "41009df5-bf11-4c97-aa18-b285b5f2e386",
      name: "Nylas Notetaker",
      join_time: 1678900000,
      meeting_link: "https://zoom.us/j/123456789",
      meeting_provider: "Zoom Meeting",
      state: "scheduled",
      meeting_settings: {
        video_recording: true,
        audio_recording: true,
        transcription: true
      }
    }, "mock_request_id"]
  end

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get method with the correct parameters with identifier" do
      identifier = "abc-123-grant-id"
      path = "#{api_uri}/v3/grants/#{identifier}/notetakers"
      allow(notetakers).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      notetaker_response = notetakers.list(identifier: identifier)

      expect(notetaker_response).to eq(list_response)
    end

    it "calls the get method with the correct parameters without identifier" do
      path = "#{api_uri}/v3/grants/notetakers"
      allow(notetakers).to receive(:get_list)
        .with(path: path, query_params: nil)
        .and_return(list_response)

      notetaker_response = notetakers.list

      expect(notetaker_response).to eq(list_response)
    end

    it "calls the get method with the correct query parameters" do
      identifier = "abc-123-grant-id"
      query_params = { state: "scheduled", limit: 50 }
      path = "#{api_uri}/v3/grants/#{identifier}/notetakers"
      allow(notetakers).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      notetaker_response = notetakers.list(identifier: identifier, query_params: query_params)

      expect(notetaker_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters with identifier" do
      identifier = "abc-123-grant-id"
      notetaker_id = "note123"
      path = "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}"
      allow(notetakers).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(response)

      notetaker_response = notetakers.find(notetaker_id: notetaker_id, identifier: identifier)

      expect(notetaker_response).to eq(response)
    end

    it "calls the get method with the correct parameters without identifier" do
      notetaker_id = "note123"
      path = "#{api_uri}/v3/grants/notetakers/#{notetaker_id}"
      allow(notetakers).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(response)

      notetaker_response = notetakers.find(notetaker_id: notetaker_id)

      expect(notetaker_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters with identifier" do
      identifier = "abc-123-grant-id"
      request_body = {
        meeting_link: "https://zoom.us/j/123456789",
        join_time: 1678900000,
        name: "Nylas Notetaker",
        meeting_settings: {
          video_recording: true,
          audio_recording: true,
          transcription: true
        }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/notetakers"
      allow(notetakers).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      notetaker_response = notetakers.create(request_body: request_body, identifier: identifier)

      expect(notetaker_response).to eq(response)
    end

    it "calls the post method with the correct parameters without identifier" do
      request_body = {
        meeting_link: "https://zoom.us/j/123456789",
        join_time: 1678900000,
        name: "Nylas Notetaker",
        meeting_settings: {
          video_recording: true,
          audio_recording: true,
          transcription: true
        }
      }
      path = "#{api_uri}/v3/grants/notetakers"
      allow(notetakers).to receive(:post)
        .with(path: path, request_body: request_body)
        .and_return(response)

      notetaker_response = notetakers.create(request_body: request_body)

      expect(notetaker_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the patch method with the correct parameters with identifier" do
      identifier = "abc-123-grant-id"
      notetaker_id = "note123"
      request_body = {
        join_time: 1678900000,
        name: "Updated Notetaker Name",
        meeting_settings: {
          video_recording: false
        }
      }
      path = "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}"
      allow(notetakers).to receive(:patch)
        .with(path: path, request_body: request_body)
        .and_return(response)

      notetaker_response = notetakers.update(
        notetaker_id: notetaker_id,
        request_body: request_body,
        identifier: identifier
      )

      expect(notetaker_response).to eq(response)
    end

    it "calls the patch method with the correct parameters without identifier" do
      notetaker_id = "note123"
      request_body = {
        join_time: 1678900000,
        name: "Updated Notetaker Name",
        meeting_settings: {
          video_recording: false
        }
      }
      path = "#{api_uri}/v3/grants/notetakers/#{notetaker_id}"
      allow(notetakers).to receive(:patch)
        .with(path: path, request_body: request_body)
        .and_return(response)

      notetaker_response = notetakers.update(
        notetaker_id: notetaker_id,
        request_body: request_body
      )

      expect(notetaker_response).to eq(response)
    end
  end

  describe "#download_media" do
    let(:media_response) do
      [{
        request_id: "mock_request_id",
        data: {
          recording: {
            url: "https://download.nylas.com/recording123.mp4",
            size: 150
          },
          transcript: {
            url: "https://download.nylas.com/transcript123.txt",
            size: 25
          }
        }
      }, "mock_request_id"]
    end

    it "calls the get method with the correct parameters with identifier" do
      identifier = "abc-123-grant-id"
      notetaker_id = "note123"
      path = "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}/media"
      allow(notetakers).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(media_response)

      media_download_response = notetakers.download_media(notetaker_id: notetaker_id, identifier: identifier)

      expect(media_download_response).to eq(media_response)
    end

    it "calls the get method with the correct parameters without identifier" do
      notetaker_id = "note123"
      path = "#{api_uri}/v3/grants/notetakers/#{notetaker_id}/media"
      allow(notetakers).to receive(:get)
        .with(path: path, query_params: nil)
        .and_return(media_response)

      media_download_response = notetakers.download_media(notetaker_id: notetaker_id)

      expect(media_download_response).to eq(media_response)
    end
  end

  describe "#leave" do
    let(:leave_response) do
      [{
        request_id: "mock_request_id",
        data: {
          id: "note123",
          message: "Notetaker has left the meeting"
        }
      }, "mock_request_id"]
    end

    it "calls the post method with the correct parameters with identifier" do
      identifier = "abc-123-grant-id"
      notetaker_id = "note123"
      path = "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}/leave"
      allow(notetakers).to receive(:post)
        .with(path: path, request_body: {})
        .and_return(leave_response)

      leave_response_result = notetakers.leave(notetaker_id: notetaker_id, identifier: identifier)

      expect(leave_response_result).to eq(leave_response)
    end

    it "calls the post method with the correct parameters without identifier" do
      notetaker_id = "note123"
      path = "#{api_uri}/v3/grants/notetakers/#{notetaker_id}/leave"
      allow(notetakers).to receive(:post)
        .with(path: path, request_body: {})
        .and_return(leave_response)

      leave_response_result = notetakers.leave(notetaker_id: notetaker_id)

      expect(leave_response_result).to eq(leave_response)
    end
  end

  describe "#cancel" do
    let(:cancel_response) do
      [true, "mock_request_id"]
    end

    it "calls the delete method with the correct parameters with identifier" do
      identifier = "abc-123-grant-id"
      notetaker_id = "note123"
      path = "#{api_uri}/v3/grants/#{identifier}/notetakers/#{notetaker_id}/cancel"
      allow(notetakers).to receive(:delete)
        .with(path: path)
        .and_return([nil, "mock_request_id"])

      cancel_response_result = notetakers.cancel(notetaker_id: notetaker_id, identifier: identifier)

      expect(cancel_response_result).to eq(cancel_response)
    end

    it "calls the delete method with the correct parameters without identifier" do
      notetaker_id = "note123"
      path = "#{api_uri}/v3/grants/notetakers/#{notetaker_id}/cancel"
      allow(notetakers).to receive(:delete)
        .with(path: path)
        .and_return([nil, "mock_request_id"])

      cancel_response_result = notetakers.cancel(notetaker_id: notetaker_id)

      expect(cancel_response_result).to eq(cancel_response)
    end
  end
end
