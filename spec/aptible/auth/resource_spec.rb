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

  describe '.all' do
    let(:session) { double Aptible::Auth::Session }
    let(:collection) { double Aptible::Auth }

    before do
      collection.stub(:sessions) { [session] }
      Aptible::Auth::Session.any_instance.stub(:find_by_url) { collection }
    end

    it 'should be an array' do
      expect(Aptible::Auth::Session.all).to be_a Array
    end

    it 'should return the root collection' do
      expect(Aptible::Auth::Session.all).to eq [session]
    end

    it 'should pass options to the HyperResource initializer' do
      klass = Aptible::Auth::Session
      options = { token: 'token' }
      expect(klass).to receive(:new).with(options).and_return klass.new
      Aptible::Auth::Session.all(options)
    end
  end

  describe '.create' do
    it 'should create a new top-level resource' do
      sessions = double Aptible::Auth
      Aptible::Auth.stub_chain(:new, :sessions) { sessions }
      expect(sessions).to receive(:create).with(foo: 'bar')
      Aptible::Auth::Session.create(foo: 'bar')
    end
  end
end
