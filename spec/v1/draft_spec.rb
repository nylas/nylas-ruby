require 'nylas'

describe Nylas::V1::Draft do
  include Nylas::V1
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @account_id = "nnnnnnn"
    @inbox = Nylas::API.new(@app_id, @app_secret, @access_token)
  end

  describe "#save!" do
    it "does save all the fields of the draft object and only sends the required JSON" do

      stub_request(:post, "https://api.nylas.com/drafts/").
        with(basic_auth: [@access_token],
        :body => '{"id":null,"account_id":"nnnnnnn","cursor":null,"created_at":null,"subject":"Test draft","snippet":null,"from":null,"to":[{"name":"Helena Handbasket","email":"helena@nylas.com"}],"reply_to":[{"name":"Reply To","email":"replyto@nylas.com"}],"cc":null,"bcc":null,"date":null,"thread_id":null,"body":null,"unread":null,"starred":null,"folder":null,"labels":null,"version":null,"reply_to_message_id":null,"file_ids":null,"tracking":null}',).to_return(:status => 200,
            :body => File.read('spec/fixtures/draft_save.txt'),
            :headers => {"Content-Type" => "application/json"})

      draft = Draft.new(@inbox)
      draft.subject = 'Test draft'
      draft.account_id = @account_id
      draft.to = [{:name => 'Helena Handbasket', :email => 'helena@nylas.com'}]
      draft.reply_to = [{:name => 'Reply To', :email => 'replyto@nylas.com'}]
      expect(draft.id).to be nil

      result = draft.save!
      expect(result.id).to_not be nil

      # Check that calling send! with a saved draft only sends the draft_id and version:
      stub_request(:post, "https://api.nylas.com/send").
         with(basic_auth: [@access_token], :body => '{"draft_id":"2h111aefv8pzwzfykrn7hercj","version":0}').to_return(:status => 200,
                   :body => File.read('spec/fixtures/send_endpoint.txt'),
                   :headers => {"Content-Type" => "application/json"})

      result.send!
    end
  end

  describe "#send!" do
    it "sends all the JSON fields when sending directly" do
      stub_request(:post, "https://api.nylas.com/send").
         with(basic_auth: [@access_token], :body => '{"id":null,"account_id":"nnnnnnn","cursor":null,"created_at":null,"subject":"Test draft","snippet":null,"from":null,"to":[{"name":"Helena Handbasket","email":"helena@nylas.com"}],"reply_to":[{"name":"Reply To","email":"replyto@nylas.com"}],"cc":null,"bcc":null,"date":null,"thread_id":null,"body":null,"unread":null,"starred":null,"folder":null,"labels":null,"version":null,"reply_to_message_id":null,"file_ids":null,"tracking":null}').to_return(:status => 200,
                 :body => File.read('spec/fixtures/send_endpoint.txt'),
                 :headers => {"Content-Type" => "application/json"})

      draft = Draft.new(@inbox)
      draft.subject = 'Test draft'
      draft.account_id = @account_id
      draft.to = [{:name => 'Helena Handbasket', :email => 'helena@nylas.com'}]
      draft.reply_to = [{:name => 'Reply To', :email => 'replyto@nylas.com'}]
      expect(draft.id).to be nil

      result = draft.send!
      expect(result.id).to_not be nil
      expect(result.snippet).to_not be ""
    end

    error_codes = Nylas::HTTP_CODE_TO_EXCEPTIONS.to_a
    error_codes.each do |error_code, exception_class|
      it "sets server_error when it is present" do
        stub_request(:post, "https://api.nylas.com/send").with(basic_auth: [@access_token]).
           to_return(:status => error_code,
                     :body => '{ "message": "Invalid recipient address benbitdiddle@gmailcom", ' +
                              '  "type": "invalid_request_error", ' +
                              '  "server_error": "SPAM"}',
                     :headers => {"Content-Type" => "application/json"})

        draft = Draft.new(@inbox)
        draft.subject = 'Test draft'
        draft.account_id = @account_id
        draft.to = [{:name => 'Helena Handbasket', :email => 'helena@nylas.com'}]
        expect(draft.id).to be nil

        begin
          draft.send!
        rescue exception_class => e
          expect(e.message).to eq("Invalid recipient address benbitdiddle@gmailcom")
          expect(e.server_error).to eq("SPAM")
        end
      end
    end

    it "sets server_error to nil when it isn't defined" do
      stub_request(:post, "https://api.nylas.com/send").with(basic_auth: [@access_token]).
         to_return(:status => 400,
                   :body => '{ "message": "Invalid recipient address benbitdiddle@gmailcom", ' +
                            '  "type": "invalid_request_error"}',
                   :headers => {"Content-Type" => "application/json"})

      draft = Draft.new(@inbox)
      draft.subject = 'Test draft'
      draft.account_id = @account_id
      draft.to = [{:name => 'Helena Handbasket', :email => 'helena@nylas.com'}]
      expect(draft.id).to be nil

      expect { draft.send! }.to raise_error(Nylas::InvalidRequest)
      begin
        draft.send!
      rescue Nylas::InvalidRequest => e
        expect(e.message).to eq("Invalid recipient address benbitdiddle@gmailcom")
        expect(e.server_error).to eq(nil)
      end
    end

  end

end
