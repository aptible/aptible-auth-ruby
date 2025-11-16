require 'spec_helper'

describe Aptible::Auth::Organization do
  describe '#security_officer' do
    let(:user) { double 'Aptible::Auth::User' }

    it 'should return the security officer' do
      allow(subject).to receive(:security_officer) { user }
      expect(subject.security_officer).to eq user
    end
  end

  describe '#create_external_aws_role!' do
    let(:params) do
      {
        aws_account_id: '123456789012',
        role_arn: 'arn:aws:iam::123456789012:role/MyRole',
        role_type: 'deploy'
      }
    end
    let(:link) { double('HyperResource::Link') }

    before do
      allow(subject).to receive(:href) { 'https://auth.aptible.com/organizations/1' }
      allow(HyperResource::Link).to receive(:new).and_return(link)
      allow(link).to receive(:post)
    end

    it 'should POST to the external_aws_roles endpoint' do
      expect(link).to receive(:post).with(params)
      subject.create_external_aws_role!(params)
    end
  end
end
