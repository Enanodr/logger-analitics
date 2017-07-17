### Basic required steps

0. Make sure you have the slacks folder with Slack's information.
1. Create base csv file from this folders running `ruby logger_analyzer`.
You'll get a `slacks_by_channel_by_slack_id.csv` file.
2. Create slack_id-email csv file running `ruby slack_id_mapper`.
You'll get a `emails_by_slack_id.csv` file.
3. Create base information file with email running `python3 slacks_per_woloxer_with_email.py`.
You'll get a `slacks_by_channel_by_woloxer_email.csv` file.


### Sentiment Analysis

1. Having run the basic steps, run `ruby sentiment_analyzer.rb`.
You'll get a `all_woloxers_with_monthly_sentiment.csv` file.
