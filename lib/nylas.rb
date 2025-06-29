# frozen_string_literal: true

require "json"
require "httparty"

require "ostruct"
require "forwardable"

require_relative "nylas/version"
require_relative "nylas/errors"
require_relative "nylas/client"
require_relative "nylas/config"

require_relative "nylas/handler/http_client"

require_relative "nylas/resources/applications"
require_relative "nylas/resources/attachments"
require_relative "nylas/resources/auth"
require_relative "nylas/resources/calendars"
require_relative "nylas/resources/connectors"
require_relative "nylas/resources/contacts"
require_relative "nylas/resources/credentials"
require_relative "nylas/resources/drafts"
require_relative "nylas/resources/events"
require_relative "nylas/resources/folders"
require_relative "nylas/resources/grants"
require_relative "nylas/resources/messages"
require_relative "nylas/resources/notetakers"
require_relative "nylas/resources/smart_compose"
require_relative "nylas/resources/threads"
require_relative "nylas/resources/redirect_uris"
require_relative "nylas/resources/webhooks"
require_relative "nylas/resources/scheduler"

require_relative "nylas/utils/file_utils"
