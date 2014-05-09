require 'spec_helper'
require 'pry'

describe Aptible::Auth::User do
  describe '#organizations' do
    let(:so) { double 'Aptible::Auth::Role' }
    let(:owner) { double 'Aptible::Auth::Role' }
    let(:org) { double 'Aptible::Auth::Organization' }

    before do
      org.stub(:id) { 1 }
      so.stub(:name) { 'Security Officers' }
      so.stub(:organization) { org }
      owner.stub(:name) { 'Owners' }
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
end
