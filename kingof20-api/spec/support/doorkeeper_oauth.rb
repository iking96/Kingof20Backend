# Reference: http://johnnyji.me/rspec/2015/06/18/stubbing-controller-instance-methods-in-rspec.html
module ApiControllerHelper
  def stub_access_token(token)
    allow_any_instance_of(ApplicationController).to receive(:doorkeeper_token).and_return(token)
  end

  def stub_current_user(user)
    allow_any_instance_of(ApplicationController).to receive(:current_resource_owner).and_return(user)
  end
end

RSpec.configure do |config|
  config.include ApiControllerHelper
end
