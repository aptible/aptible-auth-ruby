require 'spec_helper'

describe Aptible::Auth::Organization do
  describe '#security_officer' do
    let(:user) { double 'Aptible::Auth::User' }

    it 'should return the security officer' do
      allow(subject).to receive(:security_officer) { user }
      expect(subject.security_officer).to eq user
    end
  end

  describe '#external_aws_roles' do
    let(:external_aws_role) { double 'Aptible::Auth::ExternalAwsRole' }

    it 'should return the external_aws_roles' do
      allow(subject).to receive(:external_aws_roles) { [external_aws_role] }
      expect(subject.external_aws_roles).to eq [external_aws_role]
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
    let(:external_aws_role) { double('Aptible::Auth::ExternalAwsRole') }
    let(:external_aws_roles_link) { double('HyperResource::Link') }

    before do
      allow(subject).to receive(:loaded) { true }
      allow(subject).to receive(:links) { { external_aws_roles: external_aws_roles_link } }
      allow(external_aws_roles_link).to receive(:create).and_return(external_aws_role)
    end

    it 'should call create on the external_aws_roles link' do
      expect(external_aws_roles_link).to receive(:create).with(params)
      subject.create_external_aws_role!(params)
    end

    it 'should return the created external_aws_role' do
      expect(subject.create_external_aws_role!(params)).to eq external_aws_role
    end
  end
end
