# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  default from: 'noreply@kingof20.com'

  def reset_password_instructions(record, token, _opts = {})
    @token = token
    @resource = record
    # Build URL pointing to the React app root with the token as a query param
    @reset_url = "#{root_url}?reset_password_token=#{token}"

    mail(
      to: record.email,
      subject: 'Reset your King of 20 password',
      template_path: 'devise/mailer',
      template_name: 'reset_password_instructions'
    )
  end

  private

  def root_url
    host = ENV.fetch('APP_HOST', 'localhost:3000')
    protocol = Rails.env.production? ? 'https' : 'http'
    "#{protocol}://#{host}"
  end
end
