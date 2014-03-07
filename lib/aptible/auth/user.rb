module Aptible
  class Auth::User < Auth::Resource
    def verified?
      !!attributes['verified']
    end

    def organizations
      roles.map(&:organization)
    end

    def privileged_organizations
      privileged_roles.map(&:organization)
    end

    def privileged_roles
      @privileged_roles ||= roles.select(&:privileged?)
    end
  end
end
