# rubocop:disable ClassAndModuleChildren
module Aptible
  class Auth::Client < Auth::Resource
    belongs_to :user
  end
end
