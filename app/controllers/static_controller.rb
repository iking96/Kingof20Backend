class StaticController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def index
  end
end
