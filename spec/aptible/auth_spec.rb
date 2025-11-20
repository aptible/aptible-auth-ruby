require 'spec_helper'

describe Aptible::Auth do
  subject { Aptible::Auth::User.new }

  it 'should have a configurable root_url' do
    config = described_class.configuration
    expect(config).to be_a GemConfig::Configuration
    set_env 'APTIBLE_AUTH_ROOT_URL', nil do
      load 'aptible/auth.rb'
      config.reset
      expect(config.root_url).to eq 'https://auth.aptible.com'
    end
  end

  it 'uses ENV["APTIBLE_AUTH_ROOT_URL"] if defined' do
    config = described_class.configuration
    set_env 'APTIBLE_AUTH_ROOT_URL', 'http://foobar.com' do
      load 'aptible/auth.rb'
      config.reset
      expect(config.root_url).to eq 'http://foobar.com'
    end
  end

  it 'should expose the server public key' do
    Aptible::Auth::Agent.any_instance.should_receive :public_key
    Aptible::Auth.public_key
  end
end
