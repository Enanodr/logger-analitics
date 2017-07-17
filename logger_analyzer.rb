require 'indico'
require 'json'
require 'pp'
require 'csv'
require 'byebug'

channels = Dir.glob('./slacks/*').map { |dir|  dir.split('/').last }

# la estructura de slacks_by_channel va a ser
# {
#   "CHANNEL_ID" => {
#     "WOLOXER_ID" => [{
#                       "text": context of message,
#                       "time": seconds,
#                       "month": "YYYY-MM",
#                       "day": "YYYY-MM-DD",
# =>                    "words_quantity": quantity of words in message
#                     }, ...],
#     "WOLOXER_ID" => ...,
# }
slacks_by_channel = { }

# Define an array entry by channel in a hash
channels.each { |channel| slacks_by_channel[channel] = [] }

# organize all slacks by channel
slack_file_names = Dir.glob('./slacks/*/*.json')
slack_file_names.each { |slack| slacks_by_channel[slack.split('/')[2]] << JSON.parse(File.open(slack).read) }

# flatten the hash
channels.each { |channel| slacks_by_channel[channel] = slacks_by_channel[channel].flatten }
# get users from channel
channels.each { |channel| slacks_by_channel[channel] = { 'slacks' => slacks_by_channel[channel], 'woloxers' => slacks_by_channel[channel].map { |slack| slack['user'] } } }

# separate texts un texts per user
channels.each do |channel|
  slacks_by_woloxer = { }
  slacks_by_channel[channel]['woloxers'].each { |woloxer| slacks_by_woloxer[woloxer] = [] }
  slacks_by_channel[channel]['slacks'].each do |slack|
    next if slack['subtype']
    slacks_by_woloxer[slack['user']] << {
      'text' => slack['text'],
      'words_quantity' => slack['text'].split.size,
      'time' => slack['ts'],
      'month' => DateTime.strptime(slack['ts'],'%s').strftime('%Y-%m'),
      'day' => DateTime.strptime(slack['ts'],'%s').strftime('%Y-%m-%d'),
    }
  end
  slacks_by_channel[channel] = slacks_by_woloxer
end

# all woloxer user ids
 woloxers = []
 slacks_by_channel.each do |_, data|
   woloxers += data.keys
   woloxers = woloxers.uniq
 end

# la estructura va a ser
# {
#   "WOLOXER_ID" => {
#     "MONTH" => "ALL THE TEXT FROM THIS MONTH"
#     "MONTH" => "ALL THE TEXT FROM THIS MONTH"
#   },
#   WOLOXER_ID => ...
# }
# woloxers_slacks_by_month = { }
# woloxers.each do |woloxer|
#   woloxers_slacks_by_month[woloxer] = { }
#   slacks_by_channel.each  do |_, data|
#     next unless data[woloxer]
#     data[woloxer].each { |slack| woloxers_slacks_by_month[woloxer][slack['month']] = [] }
#   end
#   slacks_by_channel.each do |_, data|
#     next unless data[woloxer]
#     data[woloxer].each { |slack| woloxers_slacks_by_month[woloxer][slack['month']] << slack['text'] }
#   end
# end

#slacks_by_channel_by_woloxer
# CSV Headers
csv_array = [['woloxer_id', 'channel_id', 'month', 'day', 'timestamp', 'message', 'words_quantity']]
# generate CSV array
slacks_by_channel.each do |channel_id, data|
  data.each do |user_id, slacks|
    slacks.each do |slack|
      csv_array << [user_id, channel_id, slack['month'], slack['day'], slack['time'], slack['text'], slack['words_quantity']]
    end
  end
end
# Save CSV File
CSV.open("slacks_by_channel_by_slack_id.csv", "w") { |csv| csv_array.each { |line| csv << line } }



# CSV Headers
# 'woloxer_id', 'month', 'amount_of_messages', 'sentiment'
# csv_array = [['woloxer_id', 'month', 'amount_of_messages', 'sentiment']]

# generate CSV array
# woloxers_slacks_by_month.each do |woloxer, monthly_data|
#   monthly_data.each do |month, slacks|
#     count = slacks.count
#     all_text = slacks.join('. ')
#     sentiment = Indico.sentiment_hq all_text
#     csv_array << [woloxer, month, count, sentiment]
#     puts "#{woloxer}, #{month}, #{count}, #{sentiment}}"
#   end
# end

# woloxer, month/year, sentiment


# CSV.open("all_woloxers_with_monthly_sentiment.csv", "w") { |csv| csv_array.each { |line| csv << line } }
