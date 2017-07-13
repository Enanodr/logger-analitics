# import indicoio
# indicoio.config.api_key = 'd13dbd5c6842bc758bfef2cfdbdf30b1'
from csv import DictReader, DictWriter

with open("slacks_by_channel_by_woloxer.csv", 'r') as arch:
    arch_csv = DictReader(arch)

    # Structure:
    #   { "WOLOXER_ID" => avg_length }
    average_length_per_user = {}

    # Partial Structure:
    #   { "WOLOXER_ID" => (sum_of_lengths, quantity)) }
    for line in arch_csv:
        woloxer_id = line['woloxer_id']
        before = average_length_per_user.get(woloxer_id, (0, 0))
        after = (before[0] + len(line['message']), before[1] + 1)
        average_length_per_user[woloxer_id] = after

for woloxer, sums in average_length_per_user.items():
    average_length_per_user[woloxer] = sums[0] / sums[1]

with open("average_length_by_woloxer.csv", 'w') as final_arch:
    csv_writer = DictWriter(final_arch, fieldnames=["woloxer_slack_id", "average_message_length"])
    csv_writer.writeheader()
    for woloxer, avg_length in average_length_per_user.items():
        csv_writer.writerow({"woloxer_slack_id": woloxer, "average_message_length": avg_length})
