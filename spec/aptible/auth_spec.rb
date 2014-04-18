require 'spec_helper'

describe Aptible::Auth do
  subject { Aptible::Auth::User.new }

  it 'should have a configurable root_url' do
    config = described_class.configuration
    expect(config).to be_a GemConfig::Configuration
    expect(config.root_url).to eq 'https://auth.aptible.com'
  end

  pending 'uses ENV["APTIBLE_AUTH_ROOT_URL"] if defined' do
    config = described_class.configuration
    set_env 'APTIBLE_AUTH_ROOT_URL', 'http://foobar.com' do
      config.reset
      expect(config.root_url).to eq 'http://foobar.com'
    end
  end

  it 'should expose the server public key' do
    get = double 'get'
    Aptible::Auth::Agent.any_instance.stub(:get) { get }
    expect(get).to receive :public_key
    Aptible::Auth.public_key
  end

  describe '#bearer_token' do
    it 'should accept an Aptible::Auth::Token' do
      token = Aptible::Auth::Token.new
      token.stub(:access_token) { 'aptible_auth_token' }
      subject.stub(:token) { token }
      expect(subject.bearer_token).to eq token.access_token
    end
  end
end
