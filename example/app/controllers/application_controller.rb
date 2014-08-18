require 'inbox'

class ApplicationController < ActionController::Base

  # Add a before filter that configures Inbox using the App ID,
  # App Secret, and any available auth token in the current session.
  before_action :setup_inbox
  def setup_inbox
    config = Rails.configuration
    @inbox = Inbox::API.new(config.inbox_app_id, config.inbox_app_secret, session[:inbox_token])
  end

  def login
    callback_url = url_for(:action => 'login_callback')
    redirect_to @inbox.url_for_authentication(callback_url, 'ben@inboxapp.com')
  end

  def login_callback
    # Store the Inbox API token in the session
    session[:inbox_token] = @inbox.auth_token_for_code(params[:code])
    redirect_to action: 'index'
  end

  def index
    # Redirect to login if Inbox doesn't have an auth token
    return redirect_to action: 'login' unless @inbox.auth_token

    # Get the first namespace
    namespace = @inbox.namespaces.first

    # Print out the first five threads in the namespace
    text = ""
    namespace.threads.range(0,4).each do |thread|
        text += "#{thread.subject} - #{thread.id}<br>";
    end

    # Mark a thread as read
    thread = namespace.threads.first
    thread.mark_as_read!

    # List messages on the first thread
    text += "<br><br>"
    thread.messages.each do |message|
        text += "#{message.subject}<br>";
    end

    # Upload a file to a draft
    file = namespace.files.build({:file => File.new("./public/favicon.ico", 'rb')})
    file.save!
    
    render :text => text
  end

end
