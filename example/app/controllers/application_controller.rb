require 'inbox'

class ApplicationController < ActionController::Base

  # Add a before filter that configures Inbox using the App ID,
  # App Secret, and any available access token in the current session.
  before_action :setup_inbox
  def setup_inbox
    config = Rails.configuration
    if config.inbox_app_id == 'YOUR_APP_ID'
        raise "error, you need to configure your app secrets in config/environments"
    end
    if config.inbox_api_server
        @inbox = Inbox::API.new(config.inbox_app_id, config.inbox_app_secret, session[:inbox_token], config.inbox_api_server, config.inbox_auth_domain)
    else
        @inbox = Inbox::API.new(config.inbox_app_id, config.inbox_app_secret, session[:inbox_token])
    end
  end

  def login
    # This URL must be registered with your application in the developer portal
    callback_url = url_for(:action => 'login_callback')
    redirect_to @inbox.url_for_authentication(callback_url, '')
  end

  def login_callback
    # Store the Inbox API token in the session
    session[:inbox_token] = @inbox.token_for_code(params[:code])
    redirect_to action: 'index'
  end

  def index
    # Redirect to login if Inbox doesn't have an access token
    return redirect_to action: 'login' unless @inbox.access_token

    # Get the first namespace
    namespace = @inbox.namespaces.first

    # Wait til the sync has successfully started
    thread = namespace.threads.first
    while thread == nil do
      puts "Sync not started yet. Checking again in 2 seconds."
      sleep 2
      thread = namespace.threads.first
    end

    # Print out the first five threads in the namespace
    text = ""
    namespace.threads.range(0,4).each do |thread|
        text += "#{thread.subject} - #{thread.id}<br>";
    end

    # Print out threads with the subject 'Daily Update'
    namespace.threads.where(:subject => 'Daily Update').each do |thread|
        text += "#{thread.subject} - #{thread.id}<br>";
    end

    # List messages on the first thread
    text += "<br><br>"
    thread.messages.each do |message|
        text += "#{message.subject}<br>";
    end

    # Create a new draft
    # draft = namespace.drafts.build(
    #   :to => [{:name => 'Test Test', :email => 'test-test-test@test.test'}],
    #   :subject => "Sent by Ruby",
    #   :body => "Hi there!<strong>This is HTML</strong>"
    # )
    # draft.save!
    # draft.send!

    render :text => text
  end

end
