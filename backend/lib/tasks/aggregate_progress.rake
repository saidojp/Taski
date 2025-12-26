namespace :task do
  desc "Aggregate task progress for each user in each organization"
  task aggregate_progress: :environment do
    puts "Starting Task Progress Aggregation..."

    Organization.find_each do |org|
      puts "Processing Organization: #{org.name}"
      
      org.users.each do |user|
        # Scoped to organization tasks assigned to this user
        tasks = org.tasks.where(assignee: user)
        total = tasks.count
        completed = tasks.where(status: :done).count
        
        rate = total.positive? ? (completed.to_f / total * 100).round(2) : 0.0

        TaskStatistic.create!(
          user: user,
          organization: org,
          total_tasks: total,
          completed_tasks: completed,
          completion_rate: rate,
          created_at: Time.current
        )

        puts "  User: #{user.name} | Total: #{total} | Done: #{completed} | Rate: #{rate}%"
      end
    end

    puts "Aggregation Complete."
  end
end
