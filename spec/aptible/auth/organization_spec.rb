require 'spec_helper'

describe Aptible::Auth::Organization do
  describe '#can_manage_compliance?' do
    before { subject.stub(:billing_detail) { billing_detail } }

    context 'without a billing detail' do
      let(:billing_detail) { nil }
      it 'should return false' do
        expect(subject.can_manage_compliance?).to eq false
      end
    end

    context 'with a billing detail' do
      let(:billing_detail) { double Aptible::Billing::BillingDetail }

      it 'should return true with production plan' do
        billing_detail.stub(:plan) { 'production' }
        expect(subject.can_manage_compliance?).to eq true
      end

      it 'should return false with development plan' do
        billing_detail.stub(:plan) { 'development' }
        expect(subject.can_manage_compliance?).to eq false
      end

      it 'should return false with platform plan' do
        billing_detail.stub(:plan) { 'platform' }
        expect(subject.can_manage_compliance?).to eq false
      end
    end
  end

  describe '#security_officer' do
    let(:user) { double 'Aptible::Auth::User' }

    it 'should return the security officer' do
      subject.stub(:security_officer) { user }
      expect(subject.security_officer).to eq user
    end
  end
end
