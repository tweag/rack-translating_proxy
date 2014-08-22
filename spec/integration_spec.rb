require 'faraday'
require 'json'
require 'base64'

describe 'proxying' do
  let(:proxy_host) { 'http://localhost:5555' }

  let(:http) do
    Faraday.new(url: proxy_host) do |faraday|
      faraday.request  :url_encoded
      # faraday.response :logger
      faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  %w[get post put patch delete].each do |http_method|
    define_method(http_method) do |*args|
      @last_response = http.public_send(http_method, *args)
    end
  end

  attr_reader :last_response

  specify 'a GET request to /' do
    get '/'
    expect(last_response).to be_success
    expect(last_response.body).to include 'here is my GET request to /'
  end

  specify 'a GET request' do
    get '/a-GET-request'
    expect(last_response).to be_success
    expect(last_response.body).to include 'here is my GET request'
  end

  specify 'a POST request' do
    post '/', 'the' => 'data'
    expect(last_response).to be_success
    expect(last_response.body).to include({ 'the' => 'data' }.inspect)
  end

  specify 'a PUT request' do
    put '/', 'the' => 'data'
    expect(last_response).to be_success
    expect(last_response.body).to include({ 'the' => 'data' }.inspect)
  end

  specify 'a PATCH request' do
    patch '/', 'the' => 'data'
    expect(last_response).to be_success
    expect(last_response.body).to include({ 'the' => 'data' }.inspect)
  end

  specify 'a DELETE request' do
    delete '/', 'the' => 'data'
    expect(last_response).to be_success
    expect(last_response.body).to include({ 'the' => 'data' }.inspect)
  end

  specify 'handling a redirect' do
    get '/a-redirect'
    expect(last_response.headers['location']).to eq 'http://localhost:5555/redirected-page'
    expect(last_response.status).to be 302
  end

  context 'on a request' do
    # encoded as Base64 so it's not de-translated on the way back
    let(:received_params) { JSON.parse(Base64.decode64(last_response.body)) }

    specify 'rewriting the path' do
      get '/rewritable-path'
      expect(last_response).to be_success
    end

    specify 'rewriting the query string' do
      get '/reflect?rewrite+with+space=something'
      expect(received_params).to include 'rewrote with SPACE' => 'something'
    end

    specify 'rewriting body contents' do
      post '/reflect', 'rewrite with space' => 'something'
      expect(received_params).to include 'rewrote with SPACE' => 'something'
    end
  end

  context 'on a response' do
    specify 'rewriting links in a page' do
      get '/page-with-stuff'
      expect(last_response.body).to eq \
        '<a href="http://localhost:5555/rewritable-path?rewrite+with+space">' \
        'rewrite with space'
    end
  end
end
