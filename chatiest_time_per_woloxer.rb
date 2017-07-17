require 'indico'
require 'json'
require 'pp'
require 'csv'
require 'byebug'

def period_selector(ts)
  hour = DateTime.strptime(ts,'%s').strftime('%H').to_i
  return "#{hour}-#{hour+2}" if hour.even?
  "#{hour-1}-#{hour+1}"
end

amount_of_slacks_by_woloxer_in_period = {
  '0-2' => {},
  '2-4' => {},
  '4-6' => {},
  '6-8' => {},
  '8-10' => {},
  '10-12' => {},
  '12-14' => {},
  '14-16' => {},
  '16-18' => {},
  '18-20' => {},
  '20-22' => {},
  '22-24' => {},
}

# creates hash with period_of_time[day][woloxer] => amount_of_slacks
CSV.foreach('slacks_by_channel_by_woloxer_email.csv', headers: true, header_converters: :symbol) do |row|
  woloxer = row[:email]
  day = row[:day]
  period = period_selector(row[:timestamp])

  amount_of_slacks_by_woloxer_in_period[period][day] = amount_of_slacks_by_woloxer_in_period[period].fetch(day, {})
  amount_of_slacks_by_woloxer_in_period[period][day][woloxer] = amount_of_slacks_by_woloxer_in_period[period][day].fetch(woloxer, 0)
  amount_of_slacks_by_woloxer_in_period[period][day][woloxer] += 1
end

csv_array = [ %w(period, day, woloxer_email, amount_of_chats) ]

amount_of_slacks_by_woloxer_in_period.each do |period, daily_data|
  daily_data.each do |day, woloxer_counts|
    woloxer_counts.each do |woloxer, count|
      csv_array << [ period, day, woloxer, count ]
    end
  end
end

CSV.open("amount_of_chats_per_period_and_woloxer.csv", "w") do |csv|
  csv_array.each { |line| csv << line }
end
