import sys
import json
import requests

if (len(sys.argv) < 3):
    print "Invalid number of arguments (expected 2)"
    quit();

print "Getting the initial IPs from ", str(sys.argv[1]);

with open(sys.argv[1]) as json_data:
    txData = json.load(json_data);

# We are going to append the inventory information to each transaction

transactionData = {
    'transactions': list()
}

print "Reading data from %d Transactions" % len(txData['transactions']);

for i in range(0, len(txData['transactions'])):
    relayIP = txData['transactions'][i]['relayed_by'];
    print relayIP

    # TODO now find the IP information!
