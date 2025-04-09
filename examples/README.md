# Nylas Ruby SDK Examples

This directory contains example applications and scripts that demonstrate how to use the Nylas Ruby SDK.

## Directory Structure

```
examples/
├── README.md                 # This file
├── events/                   # Event-related examples
│   └── event_notetaker_example.rb    # Example of creating events with Notetaker
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