import sys
import json
import requests
import time

if (len(sys.argv) < 4):
    print "Invalid number of arguments (expected 3)"
    print "Usage:\n python country_mapper.py <transaction json file> <output file name> <country to export>"
    quit();

print "Getting the initial IPs from ", str(sys.argv[1]);

with open(sys.argv[1]) as json_data:
    txData = json.load(json_data);

with open('config.json') as config_info:
    configData = json.load(config_info);
    otherapiKey = configData["otherapikey"];

# We are going to append the inventory information to each transaction

transactionData = {
    'transactions': list()
}

print "Reading data from %d Transactions" % len(txData['transactions']);

for i in range(0, len(txData['transactions'])):
    relayIP = txData['transactions'][i]['relayed_by'];
    #try:
    if (i % 15 == 0):
        time.sleep(1)
    httpPacket = requests.get("http://api.ipinfodb.com/v3/ip-country/?key=" + str(otherapiKey) + "&ip=" + relayIP)
    #except Exception:
    #    countryIP = "WhoIsError"

    countryIP = (httpPacket.text.split(";")[4])
    print countryIP

    # TODO now find the IP information!
