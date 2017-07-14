require 'indico'
require 'json'
require 'pp'
require 'csv'
require 'byebug'

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
channels.each do |channel|
  slacks_by_woloxer = { }
  slacks_by_channel[channel]['woloxers'].each { |woloxer| slacks_by_woloxer[woloxer] = [] }
  slacks_by_channel[channel]['slacks'].each do |slack|
    next if slack['subtype']
    slacks_by_woloxer[slack['user']] << {
      'text' => slack['text'],
      'time' => slack['ts'],
      'month' => DateTime.strptime(slack['ts'],'%s').strftime('%Y-%m')
    }
  end
  slacks_by_channel[channel] = slacks_by_woloxer
end

# HASH STRUCTURE
# organize slacks_per_channel[woloxer][month] = amount_of_messages

amounts_of_messages_per_channel_and_woloxer =  { }
slacks_by_channel.keys.each { |k| amounts_of_messages_per_channel_and_woloxer[k] = {} }

slacks_by_channel.each do |channel, woloxer_data|
  woloxer_data.each do |woloxer, slacks|
    slacks.each do |slack|
      amounts_of_messages_per_channel_and_woloxer[channel][woloxer] = { } if amounts_of_messages_per_channel_and_woloxer[channel][woloxer] == nil
      amounts_of_messages_per_channel_and_woloxer[channel][woloxer][slack['month']] = 0 if amounts_of_messages_per_channel_and_woloxer[channel][woloxer][slack['month']] == nil
      amounts_of_messages_per_channel_and_woloxer[channel][woloxer][slack['month']] += 1
    end
  end
end

email_by_slack_id = { }

CSV.foreach("./emails_by_slack_id.csv") do |row|
  email_by_slack_id[row[0]] = row[1]
end

# CSV Headers
csv_array = [['channel_id', 'woloxer_email', 'month', 'amount_of_messages']]

# generate CSV array
amounts_of_messages_per_channel_and_woloxer.each do |channel, woloxer_data|
  woloxer_data.each do |woloxer, monthly_data|
    monthly_data.each do |month, slacks_amount|
      csv_array << [channel, email_by_slack_id[woloxer], month, slacks_amount]
    end
  end
end
# Save CSV File
CSV.open("unique_slacks_by_channel_and_woloxer.csv", "w") { |csv| csv_array.each { |line| csv << line } }
