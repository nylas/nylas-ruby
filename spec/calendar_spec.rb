describe Nylas::Calendar do
  before do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @inbox = Nylas::API.new(@app_id, @app_secret, @access_token)
  end

  it "supports retrieving the events for a particular calendar item" do
    stub_request(:get, /nylas.com\/events/).to_return(status: 200, body: "[]")
    calendar = Nylas::Calendar.new(@inbox)
    calendar.id = 1
    calendar.events.each { |e| e }

    expect(a_request(:get, "https://api.nylas.com/events?calendar_id=1&limit=100&offset=0")).to have_been_made
  end
end
