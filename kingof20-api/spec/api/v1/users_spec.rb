# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('User API', type: :request) do
  let!(:user) { create(:user) }
  let(:valid_params) { nil }

  describe 'POST /api/users' do
    let(:valid_params) do
      {
        email: 'test.account@email.com',
        username: 'test_user',
        password: '123456',
      }
    end

    subject { post '/api/users', params: { user: valid_params } }

    it 'should respond and add a new User' do
      expect { subject }.to(change { User.count }.by(1))
      expect(json).to(include(
        "email" => 'test.account@email.com',
        "username" => 'test_user',
      ))
      expect(response).to(have_http_status(200))
    end
  end

  describe 'POST /oauth/token' do
    let(:valid_params) do
      {
        username: user.username,
        password: user.password,
        grant_type: 'password',
      }
    end

    subject { post '/oauth/token', params: valid_params }

    it 'should respond with token' do
      subject
      expect(json).to(include(
        'access_token',
        'token_type',
        'expires_in',
      ))
      expect(response).to(have_http_status(200))
    end

    context 'when credentials are invalid' do
      let(:valid_params) do
        {
          username: user.username,
          password: 'wrong_password',
          grant_type: 'password',
        }
      end

      it 'should respond with error' do
        subject
        expect(json).to(include(
          'status_code',
          'message',
        ))
        expect(response).to(have_http_status(401))
      end
    end
  end

  describe 'Unauthorized request' do
    subject { get '/api/games' }

    it 'should respond with unauthorized' do
      subject
      expect(response).to(have_http_status(401))
    end
  end
end
