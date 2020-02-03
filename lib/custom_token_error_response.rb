# frozen_string_literal: true

# This module allows overriding of the usual doorkeeper error message when
# an incorrect password is input
module CustomTokenErrorResponse
  def body
    {
      status_code: 401,
      message: I18n.t('devise.failure.invalid', authentication_keys: User.authentication_keys.join('/')),
      result: [],
    }
    # or merge with existing values by
    # super.merge({key: value})
  end
end
