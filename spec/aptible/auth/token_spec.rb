require 'spec_helper'

describe Aptible::Auth::Token do
  context 'with stubbed oauth client' do
    let(:oauth) { double OAuth2::Client }
    let(:response) { double OAuth2::AccessToken }

    let(:expires_at) { Time.now - Random.rand(1000) }

    before { subject.stub(:oauth) { oauth } }

    before do
      response.stub(:to_hash) do
        {
          access_token: 'access_token',
          refresh_token: nil,
          expires_at: expires_at.to_i
        }
      end
    end

    describe '.create' do
      it 'should call #authenticate_user if passed :email and :password' do
        Aptible::Auth::Token.any_instance.should_receive(
          :authenticate_user
        ).with 'user@example.com', 'foobar', {}
        described_class.create(email: 'user@example.com', password: 'foobar')
      end

      it 'should #authenticate_client if passed a client ID and secret' do
        Aptible::Auth::Token.any_instance.should_receive(
          :authenticate_client
        ).with 'id', 'secret', 'user@example.com', {}

        described_class.create(
          client_id: 'id',
          client_secret: 'secret',
          subject: 'user@example.com'
        )
      end

      it 'should #authenticate_impersonate if passed user_href' do
        Aptible::Auth::Token.any_instance.should_receive(
          :authenticate_impersonate
        ).with('foo.href', 'aptible:user:href', {})
        described_class.create(user_href: 'foo.href')
      end

      it 'should #authenticate_impersonate if passed organization_href' do
        Aptible::Auth::Token.any_instance.should_receive(
          :authenticate_impersonate
        ).with('foo.href', 'aptible:organization:href', {})
        described_class.create(organization_href: 'foo.href')
      end

      it 'should #authenticate_impersonate if passed user_email' do
        Aptible::Auth::Token.any_instance.should_receive(
          :authenticate_impersonate
        ).with('foo@com', 'aptible:user:email', {})
        described_class.create(user_email: 'foo@com')
      end

      it 'should #authenticate_impersonate if passed user_token' do
        Aptible::Auth::Token.any_instance.should_receive(
          :authenticate_impersonate
        ).with('tok tok tok', 'aptible:token', {})
        described_class.create(user_token: 'tok tok tok')
      end

      it 'should not alter the hash it receives' do
        options = { email: 'some email' }
        options_before = options.dup
        expect { described_class.create options }.to raise_error(/Unrecognized/)
        expect(options).to eq(options_before)
      end
    end

    describe '#initialize' do
      it 'should not raise error if given no arguments' do
        expect { described_class.new }.not_to raise_error
      end
    end

    describe '#authenticate_user' do
      let(:args) { %w(user@example.com foobar) }

      before { oauth.stub_chain(:password, :get_token) { response } }

      it 'should use the password strategy' do
        params = { scope: 'manage' }
        expect(oauth.password).to receive(:get_token).with(*(args + [params]))
        subject.authenticate_user(*args)
      end

      it 'should allow the token scope to be specified' do
        args << { scope: 'read' }
        expect(oauth.password).to receive(:get_token).with(*args)
        subject.authenticate_user(*args)
      end

      it 'should set the access_token' do
        subject.authenticate_user(*args)
        expect(subject.access_token).to eq 'access_token'
      end

      it 'should set the Authorization header' do
        subject.authenticate_user(*args)
        expect(subject.headers['Authorization']).to eq 'Bearer access_token'
      end

      it 'should set the expires_at property' do
        subject.authenticate_user(*args)
        expect(subject.expires_at).to be_a Time
        expect(subject.expires_at.to_i).to eq expires_at.to_i
      end
    end

    describe '#authenticate_client' do
      let(:args) { %w(id secret user@example.com) }

      before do
        subject.stub(:signing_params_from_secret) { { algorithm: 'foobar' } }
      end
      before { oauth.stub_chain(:assertion, :get_token) { response } }

      it 'should use the assertion strategy' do
        expect(oauth.assertion).to receive(:get_token).with(
          iss: 'id',
          sub: 'user@example.com',
          algorithm: 'foobar',
          scope: 'manage'
        )
        subject.authenticate_client(*args)
      end

      it 'should allow the token scope to be specified' do
        args << { scope: 'read' }
        expect(oauth.assertion).to receive(:get_token).with(
          iss: 'id',
          sub: 'user@example.com',
          algorithm: 'foobar',
          scope: 'read'
        )
        subject.authenticate_client(*args)
      end

      it 'should replace expires_in in exp' do
        args << { expires_in: 1800 }
        Timecop.freeze do
          expect(oauth.assertion).to receive(:get_token).with(
            iss: 'id',
            sub: 'user@example.com',
            exp: Time.now.to_i + 1800,
            algorithm: 'foobar',
            scope: 'manage'
          )
          subject.authenticate_client(*args)
        end
      end

      it 'should set the access_token' do
        subject.authenticate_client(*args)
        expect(subject.access_token).to eq 'access_token'
      end

      it 'should set the Authorization header' do
        subject.authenticate_client(*args)
        expect(subject.headers['Authorization']).to eq 'Bearer access_token'
      end
    end

    describe '#authenticate_impersonate (user email)' do
      let(:args) { ['foo@bar.com', 'aptible:user:email', {}] }
      before { oauth.stub_chain(:token_exchange, :get_token) { response } }

      it 'should set the access_token' do
        subject.authenticate_impersonate(*args)
        expect(subject.access_token).to eq 'access_token'
      end

      it 'should set the Authorization header' do
        subject.authenticate_impersonate(*args)
        expect(subject.headers['Authorization']).to eq 'Bearer access_token'
      end
    end

    describe '#signing_params_from_secret' do
      let(:private_key_string) { OpenSSL::PKey::RSA.new(512).to_s }

      subject do
        lambda do |secret|
          described_class.new.send(:signing_params_from_secret, secret)
        end
      end

      it 'should return a correct :algorithm' do
        params = subject.call(private_key_string)
        expect(params[:algorithm]).to eq 'RS256'
      end

      it 'should return a correct :private_key for header/footer keys' do
        params = subject.call(private_key_string)
        expect(params[:private_key]).to be_a OpenSSL::PKey::RSA
      end

      it 'should return a correct :private_key for Base64-only keys' do
        stripped_key = private_key_string.gsub(/^-.*-$/, '').delete("\n")
        params = subject.call(stripped_key)
        expect(params[:private_key]).to be_a OpenSSL::PKey::RSA
      end
    end
  end

  describe '#oauth' do
    subject { described_class.new }

    it 'creates and caches an OAuth2::Client' do
      c = subject.send(:oauth)
      expect(subject.send(:oauth)).to be(c)
    end
  end
end
