class Api::V1::GamesController < ApplicationController
  def index
    @games = current_resource_owner.games
    json_response(@games)
  end
end
