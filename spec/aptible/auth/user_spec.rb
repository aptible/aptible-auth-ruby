require 'spec_helper'

describe Aptible::Auth::User do
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

  describe '#set_org_role_memberships' do

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

      subject.set_org_role_memberships(org, [2])
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

      subject.set_org_role_memberships(org, [1, 2])
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

      subject.set_org_role_memberships(org, [])
    end

  end
end
