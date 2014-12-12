require 'spec_helper'

describe Aptible::Auth::User do
  describe '#can_manage?' do
    let(:developer) { double 'Aptible::Auth::Role' }
    let(:owner) { double 'Aptible::Auth::Role' }
    let(:org) { double 'Aptible::Auth::Organization' }

    before do
      org.stub(:id) { 1 }
      developer.stub(:organization) { org }
      allow(developer).to receive(:privileged?).and_return(false)
      owner.stub(:organization) { org }
      allow(owner).to receive(:privileged?).and_return(true)
    end

    it 'should return false if not member of org privileged role' do
      subject.stub(:roles) { [developer] }
      expect(subject.can_manage?(org)).to eq false
    end

    it 'should return true if member of org privileged role' do
      subject.stub(:roles) { [developer, owner] }
      expect(subject.can_manage?(org)).to eq true
    end

    it 'should return false if member of no roles' do
      subject.stub(:roles) { [] }
      expect(subject.can_manage?(org)).to eq false
    end
  end

  describe '#organizations' do
    let(:so) { double 'Aptible::Auth::Role' }
    let(:owner) { double 'Aptible::Auth::Role' }
    let(:org) { double 'Aptible::Auth::Organization' }

    before do
      org.stub(:id) { 1 }
      so.stub(:organization) { org }
      owner.stub(:organization) { org }
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

  describe '#roles' do
    let(:so) { double 'Aptible::Auth::Role' }
    let(:owner) { double 'Aptible::Auth::Role' }

    before do
      so.stub(:id) { 1 }
      owner.stub(:id) { 2 }
    end

    it 'should have role' do
      subject.stub(:roles) { [so] }
      expect(subject.has_role?(so)).to eq true
      expect(subject.has_role?(owner)).to eq false
    end
  end

  describe '#set_organization_roles' do
    let(:so) { double 'Aptible::Auth::Role' }
    let(:owner) { double 'Aptible::Auth::Role' }
    let(:org) { double 'Aptible::Auth::Organization' }
    let(:owner_membership) { double 'Aptible::Auth::Membership' }
    let(:so_membership) { double 'Aptible::Auth::Membership' }

    before do
      org.stub(:id) { 1 }

      so.stub(:organization) { org }
      so.stub(:id) { 1 }

      owner.stub(:organization) { org }
      owner.stub(:id) { 2 }

      allow(Aptible::Auth::Role).to receive(:find)
        .with(1, token: 'token').and_return(so)
      allow(Aptible::Auth::Role).to receive(:find)
        .with(2, token: 'token').and_return(owner)
    end

    it 'should overwrite existing memberships' do
      subject.stub(:roles) { [so] }
      subject.stub(:token) { 'token' }
      subject.stub(:headers) { {} }
      so_membership.stub(:user) { subject }
      so_membership.stub(:role) { so }
      so.stub(:memberships) { [so_membership] }
      owner.stub(:memberships) { [] }

      expect(so_membership).to receive(:destroy)
      expect(owner).to receive(:create_membership)
        .with(user: subject, token: 'token')

      subject.set_organization_roles(org, [owner])
    end

    it 'should create new memberships' do
      subject.stub(:roles) { [] }
      subject.stub(:token) { 'token' }
      subject.stub(:headers) { {} }
      so.stub(:memberships) { [] }
      owner.stub(:memberships) { [] }

      expect(so).to receive(:create_membership)
        .with(user: subject, token: 'token')
      expect(owner).to receive(:create_membership)
        .with(user: subject, token: 'token')

      subject.set_organization_roles(org, [so, owner])
    end

    it 'should delete all existing memberships' do
      subject.stub(:roles) { [so, owner] }
      so.stub(:memberships) { [so_membership] }
      owner.stub(:memberships) { [owner_membership] }
      so_membership.stub(:user) { subject }
      so_membership.stub(:role) { so }
      owner_membership.stub(:user) { subject }
      owner_membership.stub(:role) { owner }

      expect(so_membership).to receive(:destroy)
      expect(owner_membership).to receive(:destroy)

      subject.set_organization_roles(org, [])
    end
  end
end
