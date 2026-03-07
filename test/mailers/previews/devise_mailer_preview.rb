# Preview at http://localhost:3000/rails/mailers/devise_mailer/reset_password_instructions
class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    user = User.first || User.new(username: 'TestUser', email: 'test@example.com')
    CustomDeviseMailer.reset_password_instructions(user, 'fake-reset-token-123')
  end
end
