module Aptible
  module Auth
    class Role < Resource
      belongs_to :organization

      def privileged?
        !!attributes['privileged']
      end
    end
  end
end
