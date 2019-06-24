# frozen_string_literal: true

require "json"
require "rest-client"

require "ostruct"
require "forwardable"

require_relative "nylas/version"
require_relative "nylas/errors"

require_relative "nylas/logging"
require_relative "nylas/registry"
require_relative "nylas/types"
require_relative "nylas/constraints"

require_relative "nylas/collection"
require_relative "nylas/model"

# Attribute types supported by the API
require_relative "nylas/email_address"
require_relative "nylas/event"
require_relative "nylas/event_collection"
require_relative "nylas/file"
require_relative "nylas/folder"
require_relative "nylas/im_address"
require_relative "nylas/label"
require_relative "nylas/message_headers"
require_relative "nylas/message_tracking"
require_relative "nylas/participant"
require_relative "nylas/physical_address"
require_relative "nylas/phone_number"
require_relative "nylas/recurrence"
require_relative "nylas/rsvp"
require_relative "nylas/timespan"
require_relative "nylas/web_page"
require_relative "nylas/nylas_date"
require_relative "nylas/when"

# Custom collection types
require_relative "nylas/search_collection"
require_relative "nylas/deltas_collection"

# Models supported by the API
require_relative "nylas/account"
require_relative "nylas/calendar"
require_relative "nylas/contact"
require_relative "nylas/contact_group"
require_relative "nylas/current_account"
require_relative "nylas/deltas"
require_relative "nylas/delta"
require_relative "nylas/draft"
require_relative "nylas/message"
require_relative "nylas/new_message"
require_relative "nylas/raw_message"
require_relative "nylas/thread"
require_relative "nylas/webhook"

require_relative "nylas/native_authentication"

require_relative "nylas/http_client"
require_relative "nylas/api"

# an SDK for interacting with the Nylas API
# @see https://docs.nylas.com/reference
module Nylas
  Types.registry[:account] = Types::ModelType.new(model: Account)
  Types.registry[:calendar] = Types::ModelType.new(model: Calendar)
  Types.registry[:contact] = Types::ModelType.new(model: Contact)
  Types.registry[:delta] = DeltaType.new
  Types.registry[:draft] = Types::ModelType.new(model: Draft)
  Types.registry[:email_address] = Types::ModelType.new(model: EmailAddress)
  Types.registry[:event] = Types::ModelType.new(model: Event)
  Types.registry[:file] = Types::ModelType.new(model: File)
  Types.registry[:folder] = Types::ModelType.new(model: Folder)
  Types.registry[:im_address] = Types::ModelType.new(model: IMAddress)
  Types.registry[:label] = Types::ModelType.new(model: Label)
  Types.registry[:message] = Types::ModelType.new(model: Message)
  Types.registry[:message_headers] = MessageHeadersType.new
  Types.registry[:message_tracking] = Types::ModelType.new(model: MessageTracking)
  Types.registry[:participant] = Types::ModelType.new(model: Participant)
  Types.registry[:physical_address] = Types::ModelType.new(model: PhysicalAddress)
  Types.registry[:phone_number] = Types::ModelType.new(model: PhoneNumber)
  Types.registry[:recurrence] = Types::ModelType.new(model: Recurrence)
  Types.registry[:thread] = Types::ModelType.new(model: Thread)
  Types.registry[:timespan] = Types::ModelType.new(model: Timespan)
  Types.registry[:web_page] = Types::ModelType.new(model: WebPage)
  Types.registry[:nylas_date] = NylasDateType.new
  Types.registry[:contact_group] = Types::ModelType.new(model: ContactGroup)
  Types.registry[:when] = Types::ModelType.new(model: When)
end
