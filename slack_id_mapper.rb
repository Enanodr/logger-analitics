include 'httparty'

slack_url = 'https://slack.com/api/users.list?token=xoxp-2516879529-21435805462-211884793124-0697cd757818d22120fff1d3bf3fe23e'
response = HTTParty.get slack_url
parsed_response = JSON.parse response.body
