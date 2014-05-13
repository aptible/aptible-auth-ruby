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
      expect(subject.role?(so)).to eq true
      expect(subject.role?(owner)).to eq false
    end
  end
end
