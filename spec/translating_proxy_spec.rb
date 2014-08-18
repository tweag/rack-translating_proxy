class ExampleTranslatingProxy < Rack::TranslatingProxy
  def target_host
    'https://target-host.url'
  end

  def request_mapping
    {
      'http://proxy.url:1234' => 'https://target.url:4321',
      'http://proxy.url:5678' => 'https://target.url:8765',
      'a word'                => 'another word'
    }
  end
end

describe ExampleTranslatingProxy do
  let(:app) { described_class.new }

  describe '#rewrite_env' do
    subject { app.rewrite_env(Hash.new { '' }.merge(env)) }
    let(:env) { {} }

    describe 'rewriting the uri' do
      its(['HTTP_HOST'])       { is_expected.to eq 'target-host.url' }
      its(['SERVER_PORT'])     { is_expected.to eq 443 }
      its(['rack.url_scheme']) { is_expected.to eq 'https' }
    end

    describe 'rewriting the path' do
      let(:env) { { 'REQUEST_URI' => '/path/with/a+word' } }
      its(['REQUEST_URI']) { is_expected.to eq '/path/with/another+word' }
    end

    describe 'rewriting the query string' do
      let(:env) { { 'QUERY_STRING' => 'a+word&something-else' } }
      its(['QUERY_STRING']) { is_expected.to eq 'another+word&something-else' }
    end

    describe 'rewriting the body' do
      context 'when it is a string' do
        let(:env) { { 'rack.input' => 'my+string+with+a+word' } }
        specify do
          expect(subject['rack.input'].read).to eq 'my+string+with+another+word'
        end

        its(['CONTENT_LENGTH']) { is_expected.to eq 27 }
      end

      context 'when it is a StringIO' do
        let(:env) { { 'rack.input' => StringIO.new('my+string+with+a+word') } }
        specify do
          expect(subject['rack.input'].read).to eq 'my+string+with+another+word'
        end

        its(['CONTENT_LENGTH']) { is_expected.to eq 27 }
      end
    end
  end

  describe '#rewrite_response' do
    subject { app.rewrite_response(triplet) }

    let(:triplet) { [given_status, given_headers, given_body] }
    let(:given_status)  { double }
    let(:given_body)    { double }
    let(:given_headers) do
      {
        'location' => %w(
          https://target.url:4321/path
          https://target.url:8765/path
        ),

        'status'            => ['302 Found'],
        'connection'        => ['close'],
        'transfer-encoding' => ['chunked']
      }
    end

    let(:rewritten_status)  { subject[0] }
    let(:rewritten_headers) { subject[1] }
    let(:rewritten_body)    { subject[2] }

    specify { expect(rewritten_body).to eq given_body }
    specify { expect(rewritten_status).to eq given_status }

    specify do
      expect(rewritten_headers).to eq \
        'location' => %w(http://proxy.url:1234/path http://proxy.url:5678/path)
    end
  end
end
