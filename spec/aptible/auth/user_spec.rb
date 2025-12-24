require 'spec_helper'

describe Aptible::Auth::User do
  describe '#organizations' do
    let(:org_id) { 1 }
    let(:so) { double 'Aptible::Auth::Role' }
    let(:owner) { double 'Aptible::Auth::Role' }
    let(:org) { double 'Aptible::Auth::Organization' }
    let(:organization_link) do
      double('Aptible::Auth::Organization::Link', href: '/organizations/1')
    end
    let(:role_link) { double('Aptible::Auth::Role::Link') }

    before do
      role_link.stub(:organization) { organization_link }
      organization_link.stub(:get) { org }

      org.stub(:id) { org_id }
      so.stub(:links) { role_link }
      owner.stub(:links) { role_link }
    end

    it 'should return empty if no organizations' do
      subject.stub(:roles) { [] }
      expect(subject.organizations.count).to eq 0
    end

    it 'should return unique organizations only' do
      subject.stub(:roles) { [so, owner] }
      expect(subject.organizations.count).to eq 1
    end
  end

  describe '#roles_with_organizations' do
    let(:token) { 'some-token' }
    let(:headers) { { 'Authorization' => 'Bearer some-token' } }

    let(:org1) do
      double('Aptible::Auth::Organization', href: '/organizations/1', id: 1)
    end
    let(:org2) do
      double('Aptible::Auth::Organization', href: '/organizations/2', id: 2)
    end

    let(:org1_link) do
      double('Aptible::Auth::Organization::Link', href: '/organizations/1')
    end
    let(:org2_link) do
      double('Aptible::Auth::Organization::Link', href: '/organizations/2')
    end

    let(:role1_links) { double('Role1::Links') }
    let(:role2_links) { double('Role2::Links') }
    let(:role3_links) { double('Role3::Links') }

    let(:role1) { Aptible::Auth::Role.new }
    let(:role2) { Aptible::Auth::Role.new }
    let(:role3) { Aptible::Auth::Role.new }

    before do
      subject.stub(:token) { token }
      subject.stub(:headers) { headers }

      role1_links.stub(:[]).with(:organization) { org1_link }
      role2_links.stub(:[]).with(:organization) { org2_link }
      role3_links.stub(:[]).with(:organization) { org1_link }

      role1.stub(:links) { role1_links }
      role2.stub(:links) { role2_links }
      role3.stub(:links) { role3_links }
    end

    it 'returns the roles' do
      allow(Aptible::Auth::Organization).to receive(:all).and_return([org1])
      subject.stub(:roles) { [role1] }

      expect(subject.roles_with_organizations).to eq [role1]
    end

    it 'pre-populates @organization on each role' do
      allow(Aptible::Auth::Organization).to receive(:all)
        .with(token: token, headers: headers)
        .and_return([org1, org2])
      subject.stub(:roles) { [role1, role2] }

      subject.roles_with_organizations

      expect(role1.instance_variable_get(:@organization)).to eq org1
      expect(role2.instance_variable_get(:@organization)).to eq org2
    end

    it 'maps multiple roles to the same organization' do
      allow(Aptible::Auth::Organization).to receive(:all)
        .with(token: token, headers: headers)
        .and_return([org1, org2])
      subject.stub(:roles) { [role1, role2, role3] }

      subject.roles_with_organizations

      expect(role1.instance_variable_get(:@organization)).to eq org1
      expect(role2.instance_variable_get(:@organization)).to eq org2
      expect(role3.instance_variable_get(:@organization)).to eq org1
    end

    it 'returns empty array when user has no roles' do
      allow(Aptible::Auth::Organization).to receive(:all)
        .with(token: token, headers: headers)
        .and_return([])
      subject.stub(:roles) { [] }

      expect(subject.roles_with_organizations).to eq []
    end

    it 'makes exactly one call to Organization.all' do
      expect(Aptible::Auth::Organization).to receive(:all)
        .with(token: token, headers: headers)
        .once
        .and_return([org1])
      subject.stub(:roles) { [role1] }

      subject.roles_with_organizations
    end
  end
end
