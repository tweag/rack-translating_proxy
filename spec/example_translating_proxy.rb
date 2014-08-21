require 'rack/translating_proxy'

class ExampleTranslatingProxy < Rack::TranslatingProxy
  def target_host
    'http://localhost:5556'
  end

  def request_mapping
    {
      # the proxy                what the target host thinks it is
      'http://localhost:5555' => 'http://localhost',

      'rewritable' => 'rewritten',
      'rewrite with space' => 'rewrote with SPACE'
    }
  end
end
