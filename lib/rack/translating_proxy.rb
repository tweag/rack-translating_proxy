require 'rack/proxy'

module Rack
  class TranslatingProxy < Rack::Proxy
    def rewrite_env(env)
      rewrite_request_url          env
      rewrite_request_body         env
      rewrite_request_query_string env
      rewrite_request_path         env

      env
    end

    def rewrite_request_url(env)
      env['HTTP_HOST']       = _target_host.host
      env['SERVER_PORT']     = _target_host.port
      env['rack.url_scheme'] = _target_host.scheme
    end

    def rewrite_request_body(env)
      rewritten_input = rewrite_request_string(io(env['rack.input']).read)

      env['rack.input']     = io(rewritten_input)
      env['CONTENT_LENGTH'] = rewritten_input.size
    end

    def rewrite_request_string(str)
      rewrite_string(str, request_mapping, URI.method(:encode_www_form_component))
    end

    def rewrite_request_query_string(env)
      env['QUERY_STRING'] = rewrite_request_string(env['QUERY_STRING'])
    end

    def rewrite_request_path(env)
      env['REQUEST_URI']  = rewrite_request_string(env['REQUEST_URI'])
    end

    def rewrite_string(string, mapping, transform = proc { |x| x })
      mapping = mapping.map do |source, target|
        [transform[source], transform[target]]
      end

      mapping.each do |source, target|
        string = string.gsub(source, target)
      end

      string
    end

    def io(stringy_thing)
      if stringy_thing.respond_to?(:read)
        stringy_thing
      else
        StringIO.new(stringy_thing)
      end
    end

    def rewrite_response(triplet)
      status, headers, body = triplet
      rewrite_response_location headers
      remove_interfering_response_headers headers
      [status, headers, body]
    end

    def rewrite_response_location(headers)
      if headers['location']
        headers['location'] = headers['location'].map do |location|
          rewrite_string(location, _response_mapping)
        end
      end
    end

    def remove_interfering_response_headers(headers)
      headers.reject! do |key, _|
        %w[status connection transfer-encoding].include?(key)
      end
    end

    def request_mapping
      fail 'Not implemented'
    end

    def _request_mappping
      @_request_mappping ||= request_mappping
    end

    def _response_mapping
      @_response_mapping ||= request_mapping.invert
    end

    def _target_host
      @_target_host ||= URI(target_host)
    end

    def target_host
      fail 'Not implemented'
    end
  end
end
