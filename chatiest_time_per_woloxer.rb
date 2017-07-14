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

channels = Dir.glob('./slacks/*').map { |dir|  dir.split('/').last }
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
slacks_by_woloxer = { }
channels.each { |channel| slacks_by_channel[channel]['woloxers'].each { |woloxer| slacks_by_woloxer[woloxer] = [] } }

channels.each do |channel|
  slacks_by_channel[channel]['slacks'].each do |slack|
    next if slack['subtype']
    slacks_by_woloxer[slack['user']] << {
      'text' => slack['text'],
      'time' => slack['ts'],
      'month' => DateTime.strptime(slack['ts'],'%s').strftime('%Y-%m')
    }
  end
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

email_by_slack_id = { }
CSV.foreach("./emails_by_slack_id.csv") do |row|
  email_by_slack_id[row[0]] = row[1]
end
csv_array = [ ['period', 'month', 'woloxer_email', 'amount_of_chats'] ]
# creates hash with period_of_time[month][wolower] => amount_of_slacks
slacks_by_woloxer.each do |woloxer, slacks|
  slacks.each do |slack|
    period = period_selector(slack['time'])
    # byebug
    amount_of_slacks_by_woloxer_in_period[period][slack['month']] = { } if amount_of_slacks_by_woloxer_in_period[period][slack['month']] == nil
    amount_of_slacks_by_woloxer_in_period[period][slack['month']][woloxer] = 0 if amount_of_slacks_by_woloxer_in_period[period][slack['month']][woloxer] == nil
    amount_of_slacks_by_woloxer_in_period[period][slack['month']][woloxer] += 1
    csv_array << [ period, slack['month'], email_by_slack_id[woloxer], amount_of_slacks_by_woloxer_in_period[period][slack['month']][woloxer] ]
  end
end

CSV.open("amount_of_chats_per_period_and_woloxer.csv", "w") do |csv|
  csv_array.each { |line| csv << line }
end
