# Contributing to the Nylas Ruby SDK

We'd love your help making the Nylas ruby gem better. You can email us at [support@nylas.com](mailto:support@nylas.com) if you have any questions or join us at our community Slack channel [here](http://slack-invite.nylas.com) 

Please sign the [Contributor License Agreement](https://goo.gl/forms/lKbET6S6iWsGoBbz2) before submitting pull requests. (It's similar to other projects, like NodeJS or Meteor.)

### Getting the Code Running Localy

The `bin/setup` script installs the different ruby versions we expect the gem to run on. Right now it's optimized for rbenv and Unix operating systems; support to make it play nicely with rvm and/or Windows would be appreciated!

### Submitting a Pull Request

Before submitting a pull request please make sure that all tests are passing.
Furthermore, make sure any new code you are adding is properly tested.

To run tests across all supported ruby versions, run `bin/setup` and then `bin/test`

* Pull requests *should* function across all the supported ruby versions, as defined in [.travis.yml](./.travis.yml)
* 

