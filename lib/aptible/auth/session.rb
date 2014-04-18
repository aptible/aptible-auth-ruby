module Aptible
  module Auth
    class Session < Resource
      belongs_to :user
    end
  end
end
