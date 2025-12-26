class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :assignee, class_name: 'User', optional: true

  validates :title, presence: true
  
  enum :status, { todo: 0, done: 1 }, default: :todo
end
