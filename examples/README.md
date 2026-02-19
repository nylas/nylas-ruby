# Nylas Ruby SDK Examples

This directory contains example applications and scripts that demonstrate how to use the Nylas Ruby SDK.

## Directory Structure

```
examples/
├── README.md                 # This file
├── events/                   # Event-related examples
│   └── event_notetaker_example.rb    # Example of creating events with Notetaker
├── messages/                 # Message-related examples
│   ├── message_fields_example.rb     # Example of using new message fields functionality
│   ├── file_upload_example.rb        # Example of file upload functionality with HTTParty migration
│   ├── send_streaming_attachments_example.rb  # Sending attachments from a stream (no local file)
│   └── send_message_example.rb       # Example of basic message sending functionality
└── notetaker/               # Standalone Notetaker examples
    ├── README.md            # Notetaker-specific documentation
    └── notetaker_example.rb # Basic Notetaker functionality example
```

## Running the Examples

Before running any example, make sure to:

1. Install the required dependencies:
   ```bash
   bundle install
   ```

2. Set up your environment variables:
   ```bash
   export NYLAS_API_KEY="your_api_key"
   export NYLAS_API_URI="https://api.us.nylas.com"  # Optional, defaults to this value
   ```

3. Some examples may require additional environment variables. Check the specific example's documentation or code for details.

## Available Examples

### Events
- `events/event_notetaker_example.rb`: Demonstrates how to create calendar events with Notetaker integration, including:
  - Creating an event with a Notetaker bot
  - Retrieving Notetaker details
  - Updating event and Notetaker settings

### Messages
- `messages/message_fields_example.rb`: Shows how to use the new message fields functionality, including:
  - Retrieving messages with tracking options
  - Getting raw MIME data from messages
  - Using MessageFields constants for better code readability
  - Comparing different field options (standard, headers, tracking, raw MIME)

  Additional environment variables needed:
  ```bash
  export NYLAS_GRANT_ID="your_grant_id"
  ```

- `messages/file_upload_example.rb`: Demonstrates file upload functionality with the HTTParty migration, including:
  - Sending messages with small attachments (<3MB) - handled as JSON with base64 encoding
  - Sending messages with large attachments (>3MB) - handled as multipart form data
  - Creating test files of appropriate sizes for demonstration
  - File handling logic and processing differences
  - Verification that HTTParty migration works for both upload methods

  Additional environment variables needed:
  ```bash
  export NYLAS_GRANT_ID="your_grant_id"
  export NYLAS_TEST_EMAIL="test@example.com"  # Email address to send test messages to
  ```

- `messages/send_streaming_attachments_example.rb`: Sending attachments from a stream (no local file on disk), including:
  - Passing string content from an IO/stream instead of a file path
  - Small attachments (<3MB) via JSON base64
  - Large attachments (>3MB) via multipart: `LARGE_ATTACHMENT=1 ruby ...`

  Additional environment variables needed:
  ```bash
  export NYLAS_GRANT_ID="your_grant_id"
  export NYLAS_TEST_EMAIL="test@example.com"
  ```

- `messages/send_message_example.rb`: Demonstrates basic message sending functionality, including:
  - Sending simple text messages
  - Handling multiple recipients (TO, CC, BCC)
  - Sending rich HTML content
  - Processing responses and error handling

  Additional environment variables needed:
  ```bash
  export NYLAS_GRANT_ID="your_grant_id"
  export NYLAS_TEST_EMAIL="test@example.com"  # Email address to send test messages to
  ```

### Notetaker
- `notetaker/notetaker_example.rb`: Shows basic Notetaker functionality, including:
  - Inviting a Notetaker to a meeting
  - Listing all Notetakers
  - Getting media from a Notetaker (recordings and transcripts)
  - Leaving a Notetaker session

  Prerequisites:
  - Ruby 3.0 or later
  - A Nylas API key
  - A meeting URL (Zoom, Google Meet, or Microsoft Teams)

  Additional environment variables needed:
  ```bash
  export MEETING_LINK="your_meeting_link_here"
  ```

## Contributing

When adding new examples:

1. Create them in the appropriate subdirectory based on functionality
2. Include clear documentation and comments in the code
3. List any required environment variables at the top of the file
4. Update this README.md with information about the new example

## Support

If you encounter any issues or have questions about these examples, please:
1. Check the [Nylas documentation](https://developer.nylas.com)
2. Visit our [GitHub repository](https://github.com/nylas/nylas-ruby)
3. Contact [Nylas support](https://support.nylas.com) 