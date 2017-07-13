require 'csv'
require 'byebug'

email_by_slack_id = { }

CSV.foreach("./emails_by_slack_id.csv") do |row|
  email_by_slack_id[row[0]] = row[1]
end


CSV.open("sentiment_analysis.csv", "w") do |csv|
  CSV.foreach("./all_woloxers_with_monthly_sentiment.csv") do |row|
    row_with_email = [email_by_slack_id[row[0]]] + row.last(row.size - 1)
    csv << row_with_email
  end
end
