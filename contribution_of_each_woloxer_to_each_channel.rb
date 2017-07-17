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

  amounts_of_messages_per_channel_and_woloxer[channel] = amounts_of_messages_per_channel_and_woloxer.fetch(channel, { daily: {}, monthly: {} })
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day] = amounts_of_messages_per_channel_and_woloxer[channel][:daily].fetch(day, { })
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][woloxer] = amounts_of_messages_per_channel_and_woloxer[channel][:daily][day].fetch(woloxer, 0)
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][woloxer] += 1

  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][:total] = amounts_of_messages_per_channel_and_woloxer[channel][:daily][day].fetch(:total, 0)
  amounts_of_messages_per_channel_and_woloxer[channel][:daily][day][:total] += 1

  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month] = amounts_of_messages_per_channel_and_woloxer[channel][:monthly].fetch(month, { })
  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][woloxer] = amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month].fetch(woloxer, 0)
  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][woloxer] += 1

  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][:total] = amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month].fetch(:total, 0)
  amounts_of_messages_per_channel_and_woloxer[channel][:monthly][month][:total] += 1
end

# CSV Headers
csv_array_daily = [ %w(channel_id, woloxer_email, day, contribiution, woloxer_amount_of_messages, total_amount_of_messages) ]
csv_array_monthly = [ %w(channel_id, woloxer_email, day, contribiution, woloxer_amount_of_messages, total_amount_of_messages) ]

# generate CSV array
amounts_of_messages_per_channel_and_woloxer.each do |channel, woloxer_data|
  woloxer_data[:daily].each do |day, daily_data|
    daily_total_in_channel = daily_data.fetch(:total)
    daily_data.each do |woloxer, amount_of_slacks|
      next if woloxer == :total
      csv_array_daily << [
        channel, woloxer, day, "#{amount_of_slacks.fdiv daily_total_in_channel}",
        amount_of_slacks, daily_data[:total]
      ]
    end
  end
  woloxer_data[:monthly].each do |month, monthly_data|
    monthly_total_in_channel = monthly_data.fetch(:total)
    monthly_data.each do |woloxer, amount_of_slacks|
      next if woloxer == :total
      csv_array_monthly << [
        channel, woloxer, month, "#{amount_of_slacks.fdiv monthly_total_in_channel}",
        amount_of_slacks, monthly_data[:total]
      ]
    end
  end
end


# Save CSV Files
CSV.open("daily_contribiution_per_woloxer_per_channel.csv", "w") { |csv| csv_array_daily.each { |line| csv << line } }
CSV.open("monthly_contribiution_per_woloxer_per_channel.csv", "w") { |csv| csv_array_monthly.each { |line| csv << line } }
