require 'spec_helper'

describe Aptible::Auth::ExternalAwsRole do
  describe '#organization' do
    let(:organization) { double 'Aptible::Auth::Organization' }

    it 'should return the organization' do
      allow(subject).to receive(:organization) { organization }
      expect(subject.organization).to eq organization
    end
  end

  describe '#external_aws_oidc_token!' do
    let(:token_content) { 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...' }
    let(:role_arn) { 'arn:aws:iam::123456789012:role/MyRole' }
    let(:response) do
      double(
        'response',
        body: {
          'aws_web_identity_token_file_content' => token_content,
          'aws_role_arn' => role_arn
        }
      )
    end
    let(:link) { double('HyperResource::Link') }

    before do
      allow(subject).to receive(:href) { 'https://auth.aptible.com/external_aws_roles/123' }
      allow(subject).to receive(:attributes).and_return(
        aws_account_id: '123456789012',
        role_arn: role_arn,
        role_type: 'deploy'
      )
      allow(HyperResource::Link).to receive(:new).and_return(link)
      allow(link).to receive(:post).and_return(response)
    end

    it 'should return an ExternalAwsOidcToken' do
      token = subject.external_aws_oidc_token!
      expect(token).to be_a Aptible::Auth::ExternalAwsOidcToken
      expect(token.token).to eq token_content
    end
  end
end
