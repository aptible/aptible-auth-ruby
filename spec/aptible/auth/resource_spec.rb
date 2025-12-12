require 'spec_helper'

describe Aptible::Auth::Resource do
  its(:namespace) { should eq 'Aptible::Auth' }
  its(:root_url) { should eq ENV['APTIBLE_AUTH_ROOT_URL'] || 'https://auth.aptible.com' }

  describe '#bearer_token' do
    it 'should accept an Aptible::Auth::Token' do
      token = Aptible::Auth::Token.new
      token.stub(:access_token) { 'aptible_auth_token' }
      subject.stub(:token) { token }
      expect(subject.bearer_token).to eq token.access_token
    end
  end
end
