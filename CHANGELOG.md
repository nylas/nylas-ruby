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

