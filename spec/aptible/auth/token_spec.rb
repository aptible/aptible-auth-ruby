require 'spec_helper'

describe Aptible::Auth::Token do
  let(:client) { double OAuth2::Client }
  let(:response) { double OAuth2::AccessToken }

  before { response.stub(:token) }
  before { response.stub(:refresh_token) }
  before { response.stub(:expires_at) { Time.now.to_i } }

  describe '#initialize' do
    it 'should call #authenticate_user if passed :email and :password' do
      Aptible::Auth::Token.any_instance.should_receive(
        :authenticate_user
      ).with 'user@example.com', 'foobar', {}
      described_class.new(email: 'user@example.com', password: 'foobar')
    end

    it 'should #authenticate_client if passed a client ID and secret' do
      Aptible::Auth::Token.any_instance.should_receive(
        :authenticate_client
      ).with 'id', 'secret', 'user@example.com', {}
      described_class.new(
        client_id: 'id',
        client_secret: 'secret',
        user: 'user@example.com'
      )
    end

    it 'should not raise error if given no arguments' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe '#authenticate_user' do
    let(:args) { %w(user@example.com foobar) }

    before { subject.stub(:client) { client } }
    before { client.stub_chain(:password, :get_token) { response } }

    it 'should use the password strategy' do
      params = { scope: 'manage' }
      expect(client.password).to receive(:get_token).with(*(args + [params]))
      subject.authenticate_user(*args)
    end

    it 'should allow the token scope to be specified' do
      args << { scope: 'read' }
      expect(client.password).to receive(:get_token).with(*args)
      subject.authenticate_user(*args)
    end

    it 'should set the access_token' do
      client.stub_chain(:password, :get_token, :token) { 'access_token' }
      subject.authenticate_user(*args)
      expect(subject.access_token).to eq 'access_token'
    end
  end

  describe '#authenticate_client' do
    let(:args) { %w(id secret user@example.com) }

    before do
      subject.stub(:signing_params_from_secret) { { algorithm: 'foobar' } }
    end
    before { subject.stub(:client) { client } }
    before { client.stub_chain(:assertion, :get_token) { response } }

    it 'should use the assertion strategy' do
      expect(client.assertion).to receive(:get_token).with(
        iss: 'id',
        sub: 'user@example.com',
        algorithm: 'foobar',
        scope: 'manage'
      )
      subject.authenticate_client(*args)
    end

    it 'should allow the token scope to be specified' do
      args << { scope: 'read' }
      expect(client.assertion).to receive(:get_token).with(
        iss: 'id',
        sub: 'user@example.com',
        algorithm: 'foobar',
        scope: 'read'
      )
      subject.authenticate_client(*args)
    end

    it 'should set the access_token' do
      client.stub_chain(:assertion, :get_token, :token) { 'access_token' }
      subject.authenticate_client(*args)
      expect(subject.access_token).to eq 'access_token'
    end
  end

  describe '#signing_params_from_secret' do
    let(:private_key_string) { OpenSSL::PKey::RSA.new(512).to_s }

    subject do
      lambda do |secret|
        described_class.new.send(:signing_params_from_secret, secret)
      end
    end

    it 'should return a correct :algorithm' do
      params = subject.call(private_key_string)
      expect(params[:algorithm]).to eq 'RS256'
    end

    it 'should return a correct :private_key for header/footer keys' do
      params = subject.call(private_key_string)
      expect(params[:private_key]).to be_a OpenSSL::PKey::RSA
    end

    it 'should return a correct :private_key for Base64-only keys' do
      stripped_key = private_key_string.gsub(/^-.*-$/, '').gsub("\n", '')
      params = subject.call(stripped_key)
      expect(params[:private_key]).to be_a OpenSSL::PKey::RSA
    end
  end
end
