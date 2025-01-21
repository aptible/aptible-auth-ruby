# rubocop:disable all
require 'oauth2'
require 'oauth2/strategy/token_exchange'
RSpec.describe OAuth2::Strategy::TokenExchange do
  let(:client) do
    cli = OAuth2::Client.new('abc', 'def', :site => 'http://api.example.com')
    cli.connection.builder.build do |b|
      b.adapter :test do |stub|
        stub.post('/oauth/token') do |env|
          case @mode
          when 'formencoded'
            [200, {'Content-Type' => 'application/x-www-form-urlencoded'}, 'expires_in=600&access_token=salmon&refresh_token=trout']
          when 'json'
            [200, {'Content-Type' => 'application/json'}, {"expires_in" => 600, "access_token" => "salmon", "refresh_token" => "trout"}]
          end
        end
      end
    end
    cli
  end
  subject { client.token_exchange }

  describe '#authorize_url' do
    it 'raises NotImplementedError' do
      expect { subject.authorize_url }.to raise_error(NotImplementedError)
    end
  end

  %w(json formencoded).each do |mode|
    describe "#get_token (#{mode})" do
      before do
        @mode = mode
        @access = subject.get_token('actor token', 'actor token type', 'subject token', 'subject token type')
      end

      it 'returns AccessToken with same Client' do
        expect(@access.client).to eq(client)
      end

      it 'returns AccessToken with #token' do
        expect(@access.token).to eq('salmon')
      end

      it 'returns AccessToken with #refresh_token' do
        expect(@access.refresh_token).to eq('trout')
      end

      it 'returns AccessToken with #expires_in' do
        expect(@access.expires_in).to eq(600)
      end

      it 'returns AccessToken with #expires_at' do
        expect(@access.expires_at).not_to be_nil
      end
    end
  end

end