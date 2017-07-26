require 'spec_helper'

describe Aptible::Auth::User do
  describe '#organizations' do
    let(:org_id) { 1 }
    let(:so) { double 'Aptible::Auth::Role' }
    let(:owner) { double 'Aptible::Auth::Role' }
    let(:org) { double 'Aptible::Auth::Organization' }
    let(:organization_link) do
      double('Aptible::Auth::Organization::Link', base_href: '/organizations/1')
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
end
