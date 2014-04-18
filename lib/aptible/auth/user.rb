module Aptible
  module Auth
    class User < Resource
      has_many :roles

      def verified?
        !!attributes['verified']
      end

      def organizations
        roles.map(&:organization)
      end

      def operations
        # TODO: Implement query params for /operations
        []
      end

      def privileged_organizations
        privileged_roles.map(&:organization)
      end

      def privileged_roles
        @privileged_roles ||= roles.select(&:privileged?)
      end
    end
  end
end
