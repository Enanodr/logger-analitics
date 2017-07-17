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
You'll get a `amount_of_chats_per_period_and_woloxer.csv` file.

### Contribiution to channel by woloxer

1. Having run the basic steps, run `ruby contribution_of_each_woloxer_to_each_channel.rb`.
You'll get 2 files: `daily_contribiution_per_woloxer_per_channel.csv` and `monthly_contribiution_per_woloxer_per_channel.csv` .
