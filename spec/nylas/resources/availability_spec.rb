# frozen_string_literal: true

describe Nylas::Availability do
  let(:availability) { described_class.new(client) }
  let(:response) do
    [{
      "emails": ["user1@example.com"],
      "start_time": 1659367800,
      "end_time": 1659369600
    },
     {
       "emails": ["user1@example.com"],
       "start_time": 1659376800,
       "end_time": 1659378600
     }]
  end

  describe "#list" do
    let(:list_response) do
      response
    end

    it "calls the get method with the correct parameters" do
      query_params = { "start_time": 1659376800, "end_time": 1659369600,
                       configuration_id: "confifiguration-123" }
      path = "#{api_uri}/v3/scheduling/availability"
      allow(availability).to receive(:get_list)
        .with(path: path, query_params: query_params)
        .and_return(list_response)

      availability_response = availability.list(query_params: query_params)
      expect(availability_response).to eq(list_response)
    end
  end
end
