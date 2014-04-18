require 'spec_helper'

describe Aptible::Auth::Resource do
  its(:namespace) { should eq 'Aptible::Auth'  }
  its(:root_url) { should eq 'https://auth.aptible.com' }
end
