#!/bin/bash
rm *.csv
ruby logger_analyzer.rb
echo 'Logger analyzer run'
ruby slack_id_mapper.rb
echo 'Slack id mapper run'
python3 slacks_per_woloxer_with_email.py
echo 'Base csv created: slacks_by_channel_by_woloxer_email.csv'
rm slacks_by_channel_by_slack_id.csv
rm emails_by_slack_id.csv
echo 'Unnecesary CSVs deleted'
