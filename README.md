# Savvy

`ENV`-backed configuration helper for Redis, sidekiq, etc.

Designed to manage configuration of services across Rails apps without
repeating a lot of the same library code.

Still in very alpha.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'savvy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install savvy

## Setup

Add the following to application.rb, after the call to `Bundler.require` and before `module RailsApp`:

```ruby
Bundler.require(*Rails.groups)

Savvy.initialize!

module RailsApp
  class Application < Rails::Application

  end
end
```

For non-rails usage, add `Savvy.initialize!` after you require your dependencies / set up Bundler,
and before you initialize the rest of your app.

Once it is in place, run `bundle exec savvy init` to create a `Savvyfile` that can configure your application.

## Usage

You can build an app specific namespace for general usage (e.g. memcached):

```ruby
Savvy.namespace :cache, :http, separator: '/' # => "yourapp/cache/http"
```

Redis settings are opinionated and simplified:

```ruby
# Will auto-detect based on REDISTOGO_URL, REDISCLOUD_URL, BOXEN_REDIS_URL, REDIS_URL,
# or fall back to default 'redis://localhost:6379'
Savvy.redis.url

# Uses : as a separator by default, but can be overridden
Savvy.redis.namespace(:cache) # => "yourapp:cache"

# Build a ConnectionPool of namespaced Redis connections.
Savvy.redis.build_connection_pool(:objects, size: 5, timeout: 5)

# Build a plain Redis::Namespace connection
Savvy.build_connection :cache
```

Sidekiq has a helper that builds a namespaced redis connection to keep sidekiq isolated:

```ruby
Sidekiq.configure_client do |config|
  config.redis = Savvy.sidekiq.redis_options
end

Sidekiq.configure_server do |config|
  config.redis = Savvy.sidekiq.redis_options
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/scryptmouse/savvy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
