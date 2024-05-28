# frozen_string_literal: true

require "json"
require "rest-client"

# BUGFIX
#   See https://github.com/sparklemotion/http-cookie/issues/27
#   and https://github.com/sparklemotion/http-cookie/issues/6
#
# CookieJar uses unsafe class caching for dynamically loading cookie jars.
# If two rest-client instances are instantiated at the same time (in threads), non-deterministic
# behaviour can occur whereby the Hash cookie jar isn't properly loaded and cached.
# Forcing an instantiation of the jar onload will force the CookieJar to load before the system has
# a chance to spawn any threads.
# Note that this should technically be fixed in rest-client itself, however that library appears to
# be stagnant so we're forced to fix it here.
# This object should get GC'd as it's not referenced by anything.
HTTP::CookieJar.new

require "ostruct"
require "forwardable"

require_relative "nylas_v2/version"
require_relative "nylas_v2/errors"
require_relative "nylas_v2/client"
require_relative "nylas_v2/config"

require_relative "nylas_v2/handler/http_client"

require_relative "nylas_v2/resources/applications"
require_relative "nylas_v2/resources/attachments"
require_relative "nylas_v2/resources/auth"
require_relative "nylas_v2/resources/calendars"
require_relative "nylas_v2/resources/connectors"
require_relative "nylas_v2/resources/contacts"
require_relative "nylas_v2/resources/credentials"
require_relative "nylas_v2/resources/drafts"
require_relative "nylas_v2/resources/events"
require_relative "nylas_v2/resources/folders"
require_relative "nylas_v2/resources/grants"
require_relative "nylas_v2/resources/messages"
require_relative "nylas_v2/resources/smart_compose"
require_relative "nylas_v2/resources/threads"
require_relative "nylas_v2/resources/redirect_uris"
require_relative "nylas_v2/resources/webhooks"

require_relative "nylas_v2/utils/file_utils"
