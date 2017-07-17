# import indicoio
# indicoio.config.api_key = 'd13dbd5c6842bc758bfef2cfdbdf30b1'
from csv import DictReader, DictWriter

with open("emails_by_slack_id.csv", 'r') as arch:
    arch_csv = DictReader(arch, fieldnames=["slack_id", "email"])

    # Structure:
    #   { "SLACK_ID" => email }
    emails_by_slack_id = {}

    for line in arch_csv:
        emails_by_slack_id[line['slack_id']] = line['email']

with open("slacks_by_channel_by_slack_id.csv", 'r') as arch, open("slacks_by_channel_by_woloxer_email.csv", 'w') as final_arch:
    arch_csv = DictReader(arch)
    csv_writer = DictWriter(final_arch, fieldnames=["email"] + arch_csv.fieldnames[1:])
    csv_writer.writeheader()
    for line in arch_csv:
        line["email"] = emails_by_slack_id[line["woloxer_id"]]
        line.pop("woloxer_id")
        csv_writer.writerow(line)
