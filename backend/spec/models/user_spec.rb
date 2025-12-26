require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(name: 'Test User', email: 'test@example.com', password: 'password', password_confirmation: 'password')
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user = User.new(email: 'test@example.com', password: 'password')
      expect(user).not_to be_valid
    end

    it 'is invalid with a duplicate email' do
      User.create!(name: 'User 1', email: 'test@example.com', password: 'password')
      user = User.new(name: 'User 2', email: 'test@example.com', password: 'password')
      expect(user).not_to be_valid
    end
  end
end
