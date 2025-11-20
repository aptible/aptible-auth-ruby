require 'spec_helper'

describe Aptible::Auth::ExternalAwsOidcToken do
  let(:token_content) { 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...' }
  let(:role_arn) { 'arn:aws:iam::123456789012:role/MyRole' }

  describe '#initialize' do
    it 'should accept string keys' do
      token = described_class.new(
        'aws_web_identity_token_file_content' => token_content,
        'aws_role_arn' => role_arn
      )
      expect(token.aws_web_identity_token_file_content).to eq token_content
      expect(token.aws_role_arn).to eq role_arn
    end

    it 'should accept symbol keys' do
      token = described_class.new(
        aws_web_identity_token_file_content: token_content,
        aws_role_arn: role_arn
      )
      expect(token.aws_web_identity_token_file_content).to eq token_content
      expect(token.aws_role_arn).to eq role_arn
    end
  end

  describe '#token' do
    it 'should return the token content' do
      token = described_class.new(
        aws_web_identity_token_file_content: token_content
      )
      expect(token.token).to eq token_content
    end
  end

  describe '#to_s' do
    it 'should return the token content as a string' do
      token = described_class.new(
        aws_web_identity_token_file_content: token_content
      )
      expect(token.to_s).to eq token_content
    end
  end
end
