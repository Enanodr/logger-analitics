require 'csv'
require 'indico'

# La estructura va a ser
# {
#   "WOLOXER_ID" => {
#     "MONTH" => ["TEXT FROM SLACK 1", "TEXT FROM SLACK 2", ...]
#     "MONTH" => ...
#   },
#   WOLOXER_ID => ...
# }
woloxers_slacks_by_month = { }

CSV.foreach('slacks_by_channel_by_woloxer_email.csv', headers: true, header_converters: :symbol) do |row|
  woloxer = row[:email]
  woloxers_slacks_by_month[woloxer] = woloxers_slacks_by_month.fetch(woloxer, { })
  month = row[:month]
  woloxers_slacks_by_month[woloxer][month] = woloxers_slacks_by_month[woloxer].fetch(month, [])
  woloxers_slacks_by_month[woloxer][month] << row[:raw_message]
end


# La estructura va a ser
# {
#   "WOLOXER_ID" => {
#     "MONTH" => "TEXT FROM SLACK 1. TEXT FROM SLACK 2"
#     "MONTH" => "ALL THE TEXT FROM THIS OTHER MONTH"
#   },
#   WOLOXER_ID => ...
# }

# CSV Headers
csv_array = [['woloxer_email', 'month', 'amount_of_messages', 'sentiment']]

generate CSV array
woloxers_slacks_by_month.each do |woloxer, monthly_data|
  monthly_data.each do |month, slacks|
    count = slacks.count
    all_text = slacks.join('. ')
    sentiment = Indico.sentiment_hq all_text
    csv_array << [woloxer, month, count, sentiment]
    puts "#{woloxer}, #{month}, #{count}, #{sentiment}}"
  end
end

CSV.open("all_woloxers_with_monthly_sentiment.csv", "w") { |csv| csv_array.each { |line| csv << line } }
