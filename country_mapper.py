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
txFile = open(sys.argv[2],'w')
totalTx = len(txData['transactions']);
for i in range(0, totalTx):

    # IP which first(ish) broadcasted the tx
    relayIP = txData['transactions'][i]['relayed_by'];

    # Retrieve the about that IP (including country) from this nifty API
    httpPacket = requests.get("http://api.ipinfodb.com/v3/ip-country/?key=" + str(otherapiKey) + "&ip=" + relayIP)

    # If the requests to the server fails, we wait 1 second (for rate limiting) and try again
    if (httpPacket.status_code != 200):
        time.sleep(1);
        httpPacket = requests.get("http://api.ipinfodb.com/v3/ip-country/?key=" + str(otherapiKey) + "&ip=" + relayIP)

    try:
        countryName = (httpPacket.text.split(";")[4])
    except IndexError:
        coutnryName = ""

    if (countryName.lower() == sys.argv[3].lower()):
        txFile.write(str(txData['transactions'][i]));
    out= "%d%% Complete" % ((i*100)/totalTx);
    sys.stdout.write("\033[92m")
    sys.stdout.write("\r%s" % (out));
    sys.stdout.flush();
