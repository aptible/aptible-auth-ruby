require 'spec_helper'

describe Aptible::Auth::Resource do
  describe '.collection_url' do
    it 'should use the pluralized resource name' do
      url = Aptible::Auth::Role.collection_url
      expect(url).to eq 'https://auth.aptible.com/roles'
    end
  end

  describe '.find' do
    it 'should call find_by_url' do
      url = 'https://auth.aptible.com/roles/42'
      expect(Aptible::Auth::Role).to receive(:find_by_url).with url
      Aptible::Auth::Role.find(42)
    end
  end
end
