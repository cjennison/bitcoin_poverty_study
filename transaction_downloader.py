import sys
import json
import requests

if (len(sys.argv) < 3):
    print "Invalid number of arguments (expected 2)"
    quit();

outputName = sys.argv[2];

# get config
with open('config.json') as config_info:
    configData = json.load(config_info);
    apiKey = configData["apikey"];

print "Getting Transactions from ", str(sys.argv[1]);

with open(sys.argv[1]) as json_data:
    blockData = json.load(json_data);

transactionData = {
    'transactions': list()
}

print "Reading data from %d Blocks" % len(blockData['blocks']);
for i in range(0, len(blockData['blocks'])):
    blockHeight = blockData['blocks'][i]['hash'];

    url = 'https://blockchain.info/rawblock/' + str(blockHeight) + '?format=json&api_code=' + apiKey;
    response = requests.get(url)

    block = json.loads(response.text);

    transactionData['transactions'] = transactionData['transactions'] + block['tx'];

with open(outputName, 'w') as outfile:
    json.dump(transactionData, outfile);
