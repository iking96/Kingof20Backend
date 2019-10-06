# frozen_string_literal: true
module Error
  module ErrorHandler
    def self.included(clazz)
      clazz.class_eval do
        rescue_from StandardError do |e|
          respond(
            error: :standard_error,
            error_code: 'system',
            status: 500,
            message: e.to_s
          )
        end
        rescue_from ActiveRecord::RecordNotFound do |e|
          respond(
            error: :record_not_found,
            error_code: 'system',
            status: 404,
            message: e.to_s
          )
        end
        rescue_from CustomError do |e|
          respond(
            error: e.error,
            error_code: e.error_code,
            status: e.status,
            message: e.message
          )
        end
      end
    end

    private

    def respond(error:, error_code:, status:, message:)
      json = Concerns::Render.json(error, error_code, status, message)
      json_response(json, status)
    end
  end
end
