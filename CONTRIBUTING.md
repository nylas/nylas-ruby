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

Because it's critical that we don't break the SDK for our customers, we require releasers to run some tests before releasing a new version of the gem. The test programs are located in the test/ directory. To set up them up, you'll need to copy `tests/credentials.rb.templates` as `test/credentials.rb` and edit the `APP_ID` and `APP_SECRET` with a working Nylas API app id and secret. You also need to set up a `/callback` URL in the Nylas admin panel.

You can run the programs like this:

```shell
cd tests && ruby -I../lib auth.rb
cd tests && ruby -I../lib system.rb
```
Once those all pass, you're ready to release a new version. Edit `lib/version.rb` and then run:

    bin/test
    gem build nylas.gemspec
    gem push nylas-M.m.p.gem # Update the version number

