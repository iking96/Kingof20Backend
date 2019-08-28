require 'rails_helper'

RSpec.describe 'User API', type: :request do
  let!(:user) { create(:user) }
  let(:valid_params) { nil }

  describe 'POST /api/users' do
    let(:valid_params) {
      {
        email: 'test.account@email.com',
        username: 'test_user',
        password: '123456',
      }
    }

    subject { post '/api/users', params: { user: valid_params } }

    it 'should respond' do
      expect{ subject }.to change{ User.count }.by(1)
      expect( json ).to include(
        "email" => 'test.account@email.com',
        "username" => 'test_user',
      )
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /oauth/token' do
    let(:valid_params) {
      {
        username: user.username,
        password: user.password,
        grant_type: 'password',
      }
    }

    subject { post '/oauth/token', params: valid_params }

    it 'should respond' do
      subject
      expect( json ).to include(
        'access_token',
        'token_type',
        'expires_in',
      )
      expect(response).to have_http_status(200)
    end
  end
end
