### Basic required steps


0. You will need to have installed python and ruby.
1. Make sure you have the slacks folder with Slack's information.
2. run `chmod 755 initialize.sh & sh initialize.sh`
You'll get a `slacks_by_channel_by_woloxer_email.csv` file.

### Sentiment Analysis

1. Having run the basic steps, run `ruby sentiment_analyzer.rb`.
You'll get a `all_woloxers_with_monthly_sentiment.csv` file.


### Chats per period

1. Having run the basic steps, run `ruby chatiest_time_per_woloxer.rb`.
You'll get a `amount_of_chats_per_period_and_woloxer.csv.csv` file.
