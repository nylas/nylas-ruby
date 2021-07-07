### Unreleased
- Fix issue where "302 Redirect" response codes were treated as errors #306

### 5.1.0 / 2021-06-07
* Add support for read only attributes #298
* Add `save_all_attributes` and `update_all_attributes` methods to support
  nullifying attributes. #299
* Add support new `Event` metadata feature #300  
* Fix attributes assignment for `Delta` #297  
* Fix issue where files couldn't be attached to drafts #302
* Fix exception raise when content-type is not JSON #303
* Fix issue where draft version wouldn't update after `update` or `save` #304

### 5.0.0 / 2021-05-07

* Send `Nylas-API-Version` header to API with latest supported version. #296
* Fix issue sending message using raw mime type. #294
* Support for `messages.expanded.find(id)` to return expanded message. #293
* Add support for hosted authentication #292
* Fix bug to not send `id`, `object` and `account_id` on events update call #291

### 4.6.7 / 2021-04-22

* Support for Ruby 3.
* Add support for `/free-busy` endpoint #288
* Fix issue where download a file fetch via `find` failed #258, #287

### 4.6.6 / 2021-04-06

* Add support for `notify_participants` when creating events
* Add provider attribute to account

### 4.6.5 / 2021-02-22

* Add `content_disposition` field to File
* Fix thread-safety issue in HTTP::CookieJar loading

### 4.6.4 / 2021-02-03

* fix failing http_client spec after merging main
* Skip parsing response if content is not JSON
* Add missing http status codes / errors.
* Add reply_to to NewMessage
* Add message tracking to drafts.
* Truncate the returned filename so it's less than 256 characters and compatible with rb_sysopen.
* Bump required rest client dep to >= 2.0, remove travis ci tests for rest client 1, ruby v2.3
* Use to_json helper instead of JSON.dump.

### 4.6.3 / 2020-12-18

* Remove folder on message.save for updates
* Fix JSON parsing behavior
* Fix rubocop warnings for http_client and spec
* No longer rescue json parse errors, use Yajl instead of JSON for parsing responses (due to unicode issue).
* Add specs for changes to message.save
* Store folder id in folder_id and remove folder if present before saving.
* Adding secondary_address field to physical address model

### 4.6.2 / 2020-09-08

* Add support to move `message` and `thread` between `folder`.
* Handle new attributes added to API gracefully
* Add is_primary and other new Calendar attributes

### 4.6.1 / 2020-01-06

* Fix a bug with `when` blocks when creating events
* Add support for the Event.ical_uid field

### 4.6.0 / 2019-09-25

* Add support for `/contacts/groups` endpoint.
* Fix issue when calling `.save` on `message` (https://github.com/nylas/nylas-ruby/pull/233)
* Add support for Rails 6.
* Fix issue for updating `message` with sending `label_ids` (https://github.com/nylas/nylas-ruby/pull/231)
* Support for `when` in `Nylas::Event` for more attributes.
* Add internal transfer api to support initialize related objects.
* Fix encoding issues when downloading attachments.

### 4.5.0 / 2019-04-15

* Add support for `source` attribute in Contact model

### 4.4.0 / 2019-04-05

* Add support for `/ip_addresses` endpoint
* Add optional argument for `Model#to_json`
* Reintroduce support for Ruby 2.3
* Add Rails 4 bundler support to setup script
* Specify gemfiles called in test script

### 4.3.0 / 2019-03-18

* Drop support for Ruby 2.2 and 2.3: they have reached end-of-life
* Add support for Ruby 2.5 and 2.6
* Add `scopes` argument to `Nylas::API#authenticate` for
  [selective sync](https://docs.nylas.com/docs/how-to-use-selective-sync)
* Add `Account#revoke_all`
* Add X-Nylas-Client-Id header for HTTP requests

### 4.2.4 / 2018-08-07
* Enables silent addition of fields to API without impact to SDK
* Fixes api attribute breakage on enumeration (https://github.com/nylas/nylas-ruby/issues/188)

### 4.0.0 / 2018-01-??
* Drop support for ruby 2.0 and below
* Add support for v2 of the Contacts API
* Switch to an ActiveModel/ActiveQuery compliant interface for interacting with
  objects and APIs

### 3.2.0 / 2017-11-16
* Add support for Ruby 2.4+
* Add support for Rails 4+
* Filters now work correctly for all models
* `.each` now pages requests
* Numerous other bug fixes

### 3.1.1 / 2017-06-23
* Fix deleting event request (https://github.com/nylas/nylas-ruby/issues/101)

### 3.1.0 / 2017-05-10
* Adds support for message tracking (https://github.com/cberkom)

### 3.0.0 / 2016-11-04

* Removes `interpret_http_status` to be included in `interpret_response`
* Improve error handling
* Add native authentication example code
* Add webhooks example code
* Removes experimental JRuby support

[full changelog](https://github.com/nylas/nylas-ruby/compare/v2.0.1...v3.0.0)

### 2.0.1 / 2016-02-12

* Fix folders and labels updates for threads and messages
* Revert pull request #71

[full changelog](https://github.com/nylas/nylas-ruby/compare/v2.0.0...v2.0.1)

### 2.0.0 / 2016-02-05

* Remove get_cursor method that calls deprecated generate_cursor endpoint
* Modify `delta_stream method` to remove built-in `EventMachine.run` block and allow for multiple streams. `delta_stream` must now be called from inside an `EventMachine.run` block
* `url_for_authentication` now accepts a `:state` parameter (see https://nylas.com/docs#server_side_explicit_flow for more details)

[full changelog](https://github.com/nylas/nylas-ruby/compare/v1.3.0...v2.0.0)

### 1.3.0 / 2015-12-07

* Deprecate the tags API
* Remove the archive!/unarchive! methods
* Expose `starred`, `unread`, `has_attachments` in Nylas::Thread

[full changelog](https://github.com/nylas/nylas-ruby/compare/v1.2.1...v1.3.0)

### 1.2.0 / 2015-11-19

* Add `Messages#files?` [Issue #40](https://github.com/nylas/nylas-ruby/issues/40)
* Return an external Enumerator when no block given. [Issue #42](https://github.com/nylas/nylas-ruby/issues/42) ([Steven Harman](https://github.com/stevenharman))
* Expose `folders` in the Delta Stream API.
* Add `Inbox::Error` base class for all errors. ([Steven Harman](https://github.com/stevenharman))
* Expose `sync_state` on the `/account` API. ([Steven Harman](https://github.com/stevenharman))
* Return Enumerator for #deltas when no block given
* Ruby < 1.9.3 no longer supported
* Add travis support for Mac OS X

[full changelog](https://github.com/nylas/nylas-ruby/compare/v1.1.0...v1.2.0)


### 1.1.0 / 2015-09-22

* `Message#expanded` returns an expanded version of a message
* Expose the `server_error` field when failing to send messages
* minor bug fixes
* various test cleanups ([Steven Harman](https://github.com/stevenharman))

[full changelog](https://github.com/nylas/nylas-ruby/compare/v1.0.0...v1.1.0)

