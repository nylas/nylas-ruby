<div align="center">
  <a href="https://www.nylas.com/">
    <img src="/diagrams/nylas-logo.png" alt="Nylas" height="80" />
  </a>

  <h1>Nylas Ruby SDK</h1>

  <p>
    <strong>The official Ruby SDK for Nylas — the infrastructure that powers communications</strong>
  </p>

  <p>
    <a href="https://rubygems.org/gems/nylas"><img src="https://img.shields.io/gem/v/nylas" alt="version" /></a>
    <a href="https://codecov.io/gh/nylas/nylas-ruby"><img src="https://codecov.io/gh/nylas/nylas-ruby/branch/main/graph/badge.svg?token=IKH0YMH4KA" alt="code coverage" /></a>
    <a href="https://rubygems.org/gems/nylas"><img src="https://img.shields.io/gem/dt/nylas" alt="downloads" /></a>
    <a href="LICENSE.txt"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="license" /></a>
  </p>

  <p>
    <a href="https://developer.nylas.com/docs/v3/sdks/ruby/">📖 SDK Guide</a> ·
    <a href="https://developer.nylas.com/docs/api/v3/">📚 API Reference</a> ·
    <a href="https://dashboard-v3.nylas.com/register">🚀 Sign up</a> ·
    <a href="https://github.com/orgs/nylas-samples/repositories?q=ruby">💡 Samples</a> ·
    <a href="https://forums.nylas.com">💬 Forum</a>
  </p>
</div>

<br />

The official Ruby SDK for [Nylas](https://developer.nylas.com/docs/v3/) — the infrastructure that powers communications. Integrate with Gmail, Microsoft, IMAP, Zoom, and 250+ email, calendar, and meeting providers in 5 minutes. Covers [Email](https://developer.nylas.com/docs/v3/email/), [Calendar](https://developer.nylas.com/docs/v3/calendar/), [Contacts](https://developer.nylas.com/docs/v3/email/contacts/), [Scheduler](https://developer.nylas.com/docs/v3/scheduler/), [Notetaker](https://developer.nylas.com/docs/v3/notetaker/), and [Agent Accounts](https://developer.nylas.com/docs/v3/agent-accounts/).

This repository is for contributors and anyone installing the SDK from source. If you just want to use the SDK in your app, head straight to the **[Ruby SDK guide](https://developer.nylas.com/docs/v3/sdks/ruby/)** on developer.nylas.com.

## Get started

1. [Sign up for a free Nylas account](https://dashboard-v3.nylas.com/register).
2. Follow the [getting started guide](https://developer.nylas.com/docs/v3/getting-started/) to provision an application and create your API key.
3. Bootstrap a project with the Nylas CLI:

   ```bash
   brew install nylas/nylas-cli/nylas
   nylas init
   ```

## ⚙️  Install

> **Requirements:** Ruby 3.0 or later.

Add the gem to your Gemfile:

```ruby
gem "nylas"
```

Then install:

```bash
bundle install
```

Or install it directly:

```bash
gem install nylas
```

### Build from source

```bash
git clone https://github.com/nylas/nylas-ruby.git
cd nylas-ruby
bundle install
```

Run the test suite with `rspec spec`.

## ⚡️ Usage

Initialize the client with your API key:

```ruby
require "nylas"

nylas = Nylas::Client.new(
  api_key: "NYLAS_API_KEY"
)
```

Then make a request — for example, list a grant's calendars:

```ruby
calendars, request_id, next_cursor = nylas.calendars.list(identifier: "GRANT_ID")
```

Every SDK call returns a tuple. List endpoints return `[data, request_id, next_cursor, headers]`; single-record endpoints return `[data, request_id]`. Destructure the elements you need and ignore the rest with `_`. Use `next_cursor` to paginate:

```ruby
cursor = nil
loop do
  page, _request_id, cursor = nylas.calendars.list(
    identifier: "GRANT_ID",
    query_params: { page_token: cursor }
  )
  page.each { |calendar| puts calendar[:name] }
  break unless cursor
end
```

For step-by-step walkthroughs, see the developer guides:

- [Email](https://developer.nylas.com/docs/v3/email/)
- [Calendar](https://developer.nylas.com/docs/v3/calendar/)
- [Scheduler](https://developer.nylas.com/docs/v3/scheduler/)
- [Notetaker](https://developer.nylas.com/docs/v3/notetaker/)
- [Agent Accounts](https://developer.nylas.com/docs/v3/agent-accounts/)
- [Notifications & webhooks](https://developer.nylas.com/docs/v3/notifications/)

### Error handling

The SDK raises typed errors you can rescue. API failures raise `Nylas::NylasApiError` (with `type`, `status_code`, `request_id`, `provider_error`, `headers`); OAuth failures raise `Nylas::NylasOAuthError`; request timeouts raise `Nylas::NylasSdkTimeoutError`.

```ruby
begin
  nylas.messages.find(identifier: "GRANT_ID", message_id: "MESSAGE_ID")
rescue Nylas::NylasApiError => e
  warn "Nylas API error #{e.status_code} (#{e.type}): #{e.message}"
rescue Nylas::NylasSdkTimeoutError => e
  warn "Request to #{e.url} timed out after #{e.timeout}s"
end
```

## 💡 Examples

- Local examples live in [`examples/`](examples/) (messages, events, folders, notetaker).
- The [Nylas Samples org](https://github.com/orgs/nylas-samples/repositories?q=ruby) has end-to-end Ruby apps you can clone and run.

## 🤖 AI agents

[nylas/skills](https://github.com/nylas/skills) drops Nylas into Claude Code, Cursor, Codex, and other agents that support the skills format:

```bash
npx skills add nylas/skills
/plugin marketplace add nylas/skills   # Claude Code
```

The CLI also installs an MCP server for Claude Desktop, Claude Code, Cursor, Windsurf, or VS Code:

```bash
brew install nylas/nylas-cli/nylas
nylas mcp install
```

Walkthrough: [give AI agents email access via MCP](https://cli.nylas.com/guides/give-ai-agents-email-access-via-mcp).

## 📚 Reference

- [Ruby SDK guide](https://developer.nylas.com/docs/v3/sdks/ruby/)
- [API reference](https://developer.nylas.com/docs/api/v3/)
- [Getting started](https://developer.nylas.com/docs/v3/getting-started/)
- [Email](https://developer.nylas.com/docs/v3/email/) · [Calendar](https://developer.nylas.com/docs/v3/calendar/) · [Scheduler](https://developer.nylas.com/docs/v3/scheduler/) · [Notetaker](https://developer.nylas.com/docs/v3/notetaker/) · [Agent Accounts](https://developer.nylas.com/docs/v3/agent-accounts/) · [Notifications](https://developer.nylas.com/docs/v3/notifications/)
- [Data residency](https://developer.nylas.com/docs/dev-guide/platform/data-residency/)
- [Nylas CLI](https://cli.nylas.com)
- [Forum](https://forums.nylas.com)

## ✨ Upgrading

See [CHANGELOG.md](CHANGELOG.md) for release notes, and [UPGRADE.md](UPGRADE.md) for the 5.x → 6.x migration guide. The 6.x line targets Nylas API v3; if you're still on v2.7 or earlier, stay on the 5.x SDK.

## 💙 Contributing

Bug reports, questions, and pull requests are welcome. See [Contributing.md](Contributing.md) for the workflow, and the [Nylas Forum](https://forums.nylas.com) for broader discussion.

## 🔒 Security

To report a security vulnerability, follow the [Nylas Vulnerability Disclosure Policy](https://www.nylas.com/security/vulnerability-disclosure-policy/). Please don't open a public GitHub issue for security reports.

## 🔗 Other Nylas SDKs

- [nylas-nodejs](https://github.com/nylas/nylas-nodejs)
- [nylas-python](https://github.com/nylas/nylas-python)
- [nylas-java](https://github.com/nylas/nylas-java) (Java & Kotlin)

## 📝 License

MIT — see [LICENSE.txt](LICENSE.txt).
