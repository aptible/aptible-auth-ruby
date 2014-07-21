require 'spec_helper'

describe Aptible::Auth::Organization do
  describe '#can_manage_compliance?' do
    let(:production) { double 'Aptible::Auth::Resource' }
    let(:development) { double 'Aptible::Auth::Resource' }

    before { production.stub(:type) { 'production' } }
    before { development.stub(:type) { 'development' } }

    it 'should return true with a production account' do
      subject.stub(:accounts) { [development] }
      expect(subject.can_manage_compliance?).to eq false
    end

    it 'should return false without a production account' do
      subject.stub(:accounts) { [development, production] }
      expect(subject.can_manage_compliance?).to eq true
    end
  end

  describe '#security_officer' do
    let(:role) { double 'Aptible::Auth::Role' }
    let(:user) { double 'Aptible::Auth::User' }

    before { role.stub(:name) { 'Security Officers' } }
    before { role.stub(:users) { [user] } }

    it 'should return the first member of the security officers role' do
      subject.stub(:roles) { [role] }
      expect(subject.security_officer).to eq user
    end

    it 'should return nil if there is no such role' do
      subject.stub(:roles) { [] }
      expect(subject.security_officer).to be_nil
    end
  end
end
