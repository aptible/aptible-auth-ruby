module Aptible
  module Auth
    class ExternalAwsOidcToken
      attr_reader :aws_web_identity_token_file_content, :aws_role_arn

      def initialize(attributes = {})
        @aws_web_identity_token_file_content =
          attributes['aws_web_identity_token_file_content'] ||
          attributes[:aws_web_identity_token_file_content]
        @aws_role_arn =
          attributes['aws_role_arn'] ||
          attributes[:aws_role_arn]
      end

      def to_s
        aws_web_identity_token_file_content.to_s
      end

      def token
        aws_web_identity_token_file_content
      end
    end
  end
end
