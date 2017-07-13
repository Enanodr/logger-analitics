require 'httparty'
require 'byebug'


slack_url = 'https://slack.com/api/users.list?token=' + ENV['SLACK_TOKEN']
response = HTTParty.get slack_url
parsed_response = JSON.parse response.body

email_by_slack_id = { }
parsed_response['members'].each do |member|
  email_by_slack_id[member['id']] = member['profile']['email']
end

CSV.open("emails_by_slack_id.csv", "w") { |csv| email_by_slack_id.each { |id, email| csv << [id, email] } }
