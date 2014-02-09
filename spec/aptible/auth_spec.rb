require 'spec_helper'

describe Aptible::Auth do
  it 'should have a configurable root_url' do
    config = described_class.configuration
    expect(config).to be_a GemConfig::Configuration
    expect(config.root_url).to eq 'https://auth.aptible.com'
  end

  it 'should expose the server public key' do
    get = double 'get'
    Aptible::Auth::Client.any_instance.stub(:get) { get }
    expect(get).to receive :public_key
    described_class.public_key
  end
end
