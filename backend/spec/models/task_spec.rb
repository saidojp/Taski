require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:org) { Organization.create!(name: 'Test Org') }

  it 'is invalid without a title' do
    task = Task.new(organization: org)
    expect(task).not_to be_valid
  end

  it 'defaults status to todo' do
    task = Task.create!(title: 'New Task', organization: org)
    expect(task.status).to eq('todo')
  end
end
