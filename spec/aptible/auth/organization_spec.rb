require 'spec_helper'

describe Aptible::Auth::Organization do
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

  describe '#can_manage_compliance?' do
    it 'should return true with compliance plan' do
      subject.stub(:plan) { 'production' }
      expect(subject.can_manage_compliance?).to be_true
    end

    it 'should return false without compliance plan' do
      subject.stub(:plan) { 'platform' }
      expect(subject.can_manage_compliance?).to be_false
    end
  end

  describe '#subscribed?' do
    it 'should return true with valid subscription ID' do
      subject.stub(:stripe_subscription_id) { 'sub_4YrmiVa3vMpaGA' }
      expect(subject.subscribed?).to be_true
    end

    it 'should return false without valid subscription ID' do
      expect(subject.subscribed?).to be_false
    end
  end
end
