# Rack::TranslatingProxy
[![Build Status](https://travis-ci.org/promptworks/rack-translating_proxy.png?branch=master)](https://travis-ci.org/promptworks/rack-translating_proxy.png)
[![Gem Version](https://badge.fury.io/rb/rack-translating_proxy.svg)](http://badge.fury.io/rb/rack-translating_proxy)
[![Code Climate](https://codeclimate.com/github/promptworks/rack-translating_proxy/badges/gpa.svg)](https://codeclimate.com/github/promptworks/rack-translating_proxy)
[![Dependency Status](https://gemnasium.com/promptworks/rack-translating_proxy.svg)](https://gemnasium.com/promptworks/rack-translating_proxy)

An HTTP proxy that `gsub`s the contents of the requests and responses in order to make a mostly transparent proxy.

It aids in the development and testing of integration with external services, especially when the browser has to interact with those services directly.
Often, these services will only redirect to certain, predefined URLs, but your test suite spins up its services dynamically.
This includes services like OAuth/OpenId and payment gateways (e.g. Stripe, Cybersource).

## Usage

Inherit from `Rack::TranslatingProxy` and implement `#target_host` and `#request_mapping` hook methods to customize your translating proxy Rack app.

``` ruby
class MyTranslatingProxy < Rack::TranslatingProxy
  def target_host
    # ...
  end

  def request_mapping
    # ...
  end
end
```

### Target host

``` ruby
def target_host
  'https://example.com'
end
```

Implement this method to specify which host the proxy will send all the requests to.
If the app is running on `http://localhost:5555`, then if you call `http://localhost:5555/some/path` you will actually receive the contents of `https:///example.com/some/path`

The scheme (`http://` vs `http://`) does not need to match between the proxy and target host.

There is no need to memoize this method.

### Request mapping

``` ruby
def request_mapping
  {
    'some string'       => 'another string',
    'some other string' => 'another another string'
  }
end
```

Implement this method to specify which strings will be translated and to what. On requests, the keys will be translated to the values, and in the responses, the values will be translated into the keys.
In this example, in the request, any instance or `some string` will be translated to `another string` before the proxy makes the request to the target host. When the target host responds, the proxy will translate any instance of `another string` into `some string`.

On the request, the proxy will `gsub` the path, the query string, the `location` header(s) and the request body. On the response, the proxy will `gsub` the response body.

You will often want to include a rule for the target host to rewrite the proxy's current URL to the target host's URL.
This is useful particularly for handling redirects.
For example, if you have a mapping rule like `'http://localost:5555' => 'https://externalservice.com'`, when a service redirects to `https://externalservice.com/payment-accepted`, the proxy will rewrite that to `http://localhost:555/payment-accepted`.

There is no need to memoize this method.


### Example: OAuth service

Here is an example of a translating proxy for an OAuth service.

``` ruby
class OAuthProxy < Rack::TranslatingProxy
  # the host to proxy
  def target_host
    'https://externalservice.com'
  end

  def request_mapping
    {
      # the URI of this proxy => URI of the target
      'http://localhost:5555' => target_host,

      # our dev app server    => URI that the OAuth implementation has on
      #                          file and wants to redirect to
      'http://localhost:3000' => 'https://dev.mydomain.com',
    }
  end
end
```

Assuming you run the proxy on `localhost:5555`, you can configure your OAuth-enabled app to point to `http://localhost:5555`.
Your test suite and your browser can hit the real OAuth server.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-translating_proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-translating_proxy

## Development

Make sure you are running the test servers:

    ./spec/script/example_target_host
    ./spec/script/example_translating_proxy

Then, run

    rake

The test servers will update automatically because they are using [shotgun](https://github.com/rtomayko/shotgun).
If you don't need them to reload on every request, run one or both of them with the `fast` parameter, like

    ./spec/script/example_target_host fast

## Contributing

1. Fork it ( http://github.com/promptworks/rack-translating_proxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
