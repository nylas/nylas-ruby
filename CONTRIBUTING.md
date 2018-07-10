# Contributing to the Nylas Ruby SDK

We'd love your help making the Nylas ruby gem better. You can email us at [support@nylas.com](mailto:support@nylas.com) if you have any questions or join us at our community Slack channel [here](http://slack-invite.nylas.com)

Please sign the [Contributor License Agreement](https://goo.gl/forms/lKbET6S6iWsGoBbz2) before submitting pull requests. (It's similar to other projects, like NodeJS or Meteor.)

### Getting the Code Running Localy

The `bin/setup` script installs the different ruby versions we expect the gem to run on. Right now it's optimized for rbenv and Unix operating systems; support to make it play nicely with rvm and/or Windows would be appreciated!

### Submitting a Pull Request

* Pull requests *may* be submitted before they are feature complete, to get feedback and thoughts from the core team.
* Pull requests *should* pass tests across the supported ruby versions, as defined in [.travis.yml](./.travis.yml). To do so, run `bin/test`
* Pull requests *should* add new tests to cover the functionality that is added or bug that is fixed.

### Releasing Gems

#### API self-tests

Because it's critical that we don't break the SDK for our customers, we require releasers to run some tests before releasing a new version of the gem. The test programs are located in the examples/ directory. To set up them up, you'll need to copy `.env.example` to `.env` and edit it to provide real credentials.

You can run the basic examples like this:
```shell
dotenv ruby examples/plain-ruby.rb # Execute the examples in plain old ruby
```
To manually check that the authentication features still work follow the instructions in `examples/authentication/README.md`

#### Authenticating to Rubygems

Nylas team members can authenticate with the following:

```
curl -u nylas https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials; chmod 0600 ~/.gem/credentials
```

#### Pushing to Rubygems

Once the tests all pass, you're ready to release a new version!
Update `lib/nylas/version.rb` to the next planned release version then run:

```
bin/test
bin/release
```
