require 'spec_helper'

describe Aptible::Auth::Client do
  describe '#initialize' do
    it 'should be a HyperResource instance' do
      expect(subject).to be_a HyperResource
    end
  end
end
