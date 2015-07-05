require 'spec_helper'

describe Aptible::Auth::Organization do
  describe '#security_officer' do
    let(:user) { double 'Aptible::Auth::User' }

    it 'should return the security officer' do
      subject.stub(:security_officer) { user }
      expect(subject.security_officer).to eq user
    end
  end

  describe '#billing_contact' do
    let(:user) { double 'Aptible::Auth::User' }

    it 'should return the security officer' do
      subject.stub(:billing_contact) { user }
      expect(subject.billing_contact).to eq user
    end
  end

  describe '#can_manage_compliance?' do
    it 'should return true with compliance plan' do
      subject.stub(:billing_details) { OpenStruct.new(plan: 'production') }
      expect(subject.can_manage_compliance?).to be_true
    end

    it 'should return false without compliance plan' do
      subject.stub(:billing_details) { OpenStruct.new(plan: 'platform') }
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
