# Rack::TranslatingProxy
[![Build Status](https://travis-ci.org/promptworks/rack-translating_proxy.png?branch=master)](https://travis-ci.org/promptworks/rack-translating_proxy.png)

A Proxy that `gsub`s the contents of the requests and responses in order to make a mostly transparent proxy.
Its purpose is to aid in development and testing of integration with external services, especially when the browser has to interact with those services directly.

## Usage

TODO: Write usage instructions here

## Installation

Add this line to your application's Gemfile:

    gem 'rack-translating_proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-translating_proxy

## Contributing

1. Fork it ( http://github.com/<my-github-username>/rack-translating_proxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
