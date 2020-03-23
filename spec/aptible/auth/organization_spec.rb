require 'spec_helper'

describe Aptible::Auth::Organization do
  describe '#security_officer' do
    let(:user) { double 'Aptible::Auth::User' }

    it 'should return the security officer' do
      subject.stub(:security_officer) { user }
      expect(subject.security_officer).to eq user
    end
  end
end
