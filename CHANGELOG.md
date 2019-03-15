### Unreleased

nothing yet

### 4.3.0 / 2019-03-15
* Drop support for Ruby 2.2 and 2.3: they have reached end-of-life
* Add support for Ruby 2.5 and 2.6
* Add `scopes` argument to `Nylas::API#authenticate` for
  [selective sync](https://docs.nylas.com/docs/how-to-use-selective-sync)
* Add `Account#revoke_all`

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

