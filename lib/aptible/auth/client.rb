module Aptible
  module Auth
    class Client < Resource
      belongs_to :user
    end
  end
end
