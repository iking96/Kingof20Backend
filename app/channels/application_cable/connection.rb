# frozen_string_literal: true
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = current_resource_owner
    end

    protected

    def current_resource_owner
      user = User.find_by(id: doorkeeper_token.try(:resource_owner_id))

      user || reject_unauthorized_connection
    end

    # this will still allow expired tokens
    # you will need to check if token is valid with something like
    #  doorkeeper_token&.acceptable?(@_doorkeeper_scopes)
    # Taken from: https://stackoverflow.com/questions/49778736/is-it-possible-use-doorkeeper-with-action-cable
    def doorkeeper_token
      params = request.query_parameters

      @access_token ||= Doorkeeper::AccessToken.by_token(params[:access_token])
    end
  end
end
