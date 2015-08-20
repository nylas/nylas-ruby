require 'inbox'
require 'rest-client'

begin
  load 'credentials.rb'
rescue LoadError
  puts "It seems you didn't create a 'credentials.rb' file. Look at credentials.rb.template for an example."
  exit
end

def color_print(str)
  puts "\033[0m\033[94m"
  print str
  STDIN.getc
  puts "\033[0m"
end

puts <<-eos

      _   _       _
     | \ | |     | |
     |  \| |_   _| | __ _ ___
     | . ` | | | | |/ _` / __|
     | |\  | |_| | | (_| \__ \\
     \_| \_/\__, |_|\__,_|___/
             __/ |
            |___/
\033[0m\033[94m
      A P I  S E L F - T E S T\033[0m

\n\n
Hiya! Welcome to the Ruby SDK test program. I need your help to make sure we didn't break the SDK.

Could you confirm that the following API functions didn't break?
    eos



inbox = Inbox::API.new(APP_ID, APP_SECRET, AUTH_TOKEN, api_path='https://api-staging-experimental.nylas.com')

puts "Thread count: #{inbox.threads.count}"
color_print "Did you see a thread count? (Y/N)"

threads = inbox.threads.each do |thread|
  puts thread.subject
end
color_print "Did you see a list of thread subjects? (Y/N)"

threads = inbox.threads.where(:in => 'sent').each do |thread|
  puts thread.subject
end
color_print "Did you see a list of sent threads? (Y/N)"


draft = inbox.drafts.build(:to =>  [{email: DEST_EMAIL}], :body => 'Hey, this is a test').send!
color_print "Did you receive an email? (Y/N)"

messages = inbox.messages.where(:in => 'inbox')
puts messages.first.raw
color_print "Did you see the contents of a message? (Y/N)"

first_calendar_id = inbox.calendars.first.id
puts inbox.calendars.find(first_calendar_id).name
color_print "Did you see the title of the first calendar? (Y/N)"

account = inbox.account
puts account.provider
color_print "Did you see the provider type? (Y/N)"

if account.provider == 'eas'
  inbox.folders.each do |folder|
    puts folder.display_name
  end
end

if account.provider == 'gmail'
  inbox.labels.each do |label|
    puts label.display_name
  end
end
color_print "Did you see a list of folders/labels? (Y/N)"

message = inbox.messages.first
if account.provider == 'eas'
  first_folder = inbox.folders.first
  message.folder = first_folder
  message.save!
  color_print "Did the first message get the folder #{first_folder.display_name}? (Y/N)"
elsif account.provider == 'gmail'
  message.labels.push(first_label)
  message.save!
  color_print "Did the first message get the label #{first_label.display_name}? (Y/N)"
end

cursor = inbox.get_cursor(0)
color_print "Do you see a cursor (Y/N)? #{cursor}"

cursor = inbox.latest_cursor
color_print "Do you see another cursor (Y/N)? #{cursor}"

puts "Getting events from the delta stream (this hangs eventually, feel free to Ctrl-C)"
inbox.delta_stream(cursor, exclude=[Inbox::Tag]) do |event, obj|
  if obj.is_a?(Inbox::Event)
    puts obj.title
  end
end

