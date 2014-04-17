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
end
