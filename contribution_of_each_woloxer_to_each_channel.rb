require 'json'
require 'pp'
require 'csv'
require 'byebug'


amounts_of_messages_per_channel_and_woloxer =  { }
amounts_of_messages_per_channel_and_woloxer =  { }
# creates hash with period_of_time[day][woloxer] => amount_of_slacks
CSV.foreach('slacks_by_channel_by_woloxer_email.csv', headers: true, header_converters: :symbol) do |row|
  channel = row[:channel_id]
  woloxer = row[:email]
  day = row[:day]
  month = row[:month]
  text = row[:raw_message] || ''
  # puts "Channel: #{channel}, Woloxer: #{woloxer}, dat: #{day}, text: #{row[:raw_message]}"
  amount_of_words = text.split(' ').map { |t| t.split(',') }.flatten.count

  amounts_of_messages_per_channel_and_woloxer[channel] =
    amounts_of_messages_per_channel_and_woloxer.fetch(channel, { daily: {}, monthly: {} })
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day] =
    amounts_of_messages_per_channel_and_woloxer[channel][:daily].fetch(day, { })
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][woloxer] =
    amounts_of_messages_per_channel_and_woloxer[channel][:daily][day].fetch(woloxer, { slacks: 0, words: 0 })
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][woloxer][:slacks] += 1
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][woloxer][:words] += amount_of_words

  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][:total_slacks] =
    amounts_of_messages_per_channel_and_woloxer[channel][:daily][day].fetch(:total_slacks, 0)
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][:total_slacks] += 1
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][:total_words] =
    amounts_of_messages_per_channel_and_woloxer[channel][:daily][day].fetch(:total_words, 0)
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][:total_words] += amount_of_words

  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month] =
    amounts_of_messages_per_channel_and_woloxer[channel][:monthly].fetch(month, { })
  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][woloxer] =
    amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month].fetch(woloxer, { slacks: 0, words: 0 })
  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][woloxer][:slacks] += 1
  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][woloxer][:words] += amount_of_words

  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][:total_slacks] =
    amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month].fetch(:total_slacks, 0)
  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][:total_slacks] += 1
  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][:total_words] =
    amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month].fetch(:total_words, 0)
  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][:total_words] += amount_of_words
end

# CSV Headers
csv_array_daily = [
  %w(channel_id, woloxer_email, day, message_contribiution, words_contribiution,
     woloxer_amount_of_messages, total_amount_of_messages, amount_of_words, total_amount_of_words)
]
csv_array_monthly = [
  %w(channel_id, woloxer_email, month, message_contribiution, words_contribiution,
     woloxer_amount_of_messages, total_amount_of_messages, amount_of_words, total_amount_of_words)
]

# generate CSV array
amounts_of_messages_per_channel_and_woloxer.each do |channel, woloxer_data|
  woloxer_data[:daily].each do |day, daily_data|
    daily_total_slacks_in_channel = daily_data.fetch(:total_slacks)
    daily_total_words_in_channel = daily_data.fetch(:total_words)
    daily_data.each do |woloxer, counts|
      next if [:total_slacks, :total_words].include? woloxer
      csv_array_daily << [
        channel, woloxer, day, "#{counts[:slacks].fdiv daily_total_slacks_in_channel}",
        "#{counts[:words].fdiv daily_total_words_in_channel}", counts[:slacks],
        daily_total_slacks_in_channel, counts[:words], daily_total_words_in_channel
      ]
    end
  end
  woloxer_data[:monthly].each do |month, monthly_data|
    monthly_total_slacks_in_channel = monthly_data.fetch(:total_slacks)
    monthly_total_words_in_channel = monthly_data.fetch(:total_words)
    monthly_data.each do |woloxer, counts|
      next if [:total_slacks, :total_words].include? woloxer
      csv_array_monthly << [
        channel, woloxer, month, "#{counts[:slacks].fdiv monthly_total_slacks_in_channel}",
        "#{counts[:words].fdiv monthly_total_words_in_channel}", counts[:slacks],
        monthly_total_slacks_in_channel, counts[:words], monthly_total_words_in_channel
      ]
    end
  end
end


# Save CSV Files
CSV.open("daily_contribiution_per_woloxer_per_channel.csv", "w") { |csv| csv_array_daily.each { |line| csv << line } }
CSV.open("monthly_contribiution_per_woloxer_per_channel.csv", "w") { |csv| csv_array_monthly.each { |line| csv << line } }
