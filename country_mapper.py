import sys
import json
import requests
import time

from requests.adapters import HTTPAdapter

s = requests.Session()

if (len(sys.argv) < 4):
    print "Invalid number of arguments (expected 3)"
    print "Usage:\n python country_mapper.py <transaction json file> <output file name> <country to export>"
    quit();

print "Getting the initial IPs from ", str(sys.argv[1]);
print "             Remember to use CTRL-Z to Stop me!"

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

filteredTxFile = sys.argv[2]
totalTx = len(txData['transactions']);

for i in range(0, totalTx):

    # IP which first(ish) broadcasted the tx
    relayIP = txData['transactions'][i]['relayed_by'];
    if relayIP == "127.0.0.1":
        continue;

    try:
        # Retrieve the about that IP (including country) from this nifty API
        httpPacket = requests.get("http://api.ipinfodb.com/v3/ip-country/?key=" + str(otherapiKey) + "&ip=" + relayIP, timeout=None)

        # If the requests to the server fails, we wait 1 second (for rate limiting) and try again
        if (httpPacket.status_code != 200):
            time.sleep(20);
            httpPacket = requests.get("http://api.ipinfodb.com/v3/ip-country/?key=" + str(otherapiKey) + "&ip=" + relayIP, timeout=None)
    except:
        print "Fatal Error Getting Packet, Skipping ... "
        time.sleep(5); #sleep for a few seconds if we fail.
        continue;


    try:
        countryName = (httpPacket.text.split(";")[4])
    except IndexError:
        coutnryName = ""

    if (countryName.lower() == sys.argv[3].lower()):
        transactionData['transactions'].append(txData['transactions'][i]);
        with open(filteredTxFile, 'w') as outfile:
            json.dump(transactionData, outfile);

    out= "%d%% Complete" % ((i*100)/totalTx);
    sys.stdout.write("\r%s" % (out));
    sys.stdout.flush();
