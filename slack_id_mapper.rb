include 'httparty'

token = "token=#{ENV[SLACK_ID]}"
slack_url = 'https://slack.com/api/users.list?' + token
response = HTTParty.get slack_url
parsed_response = JSON.parse response.body
