import sys
import json
import requests
import time

if (len(sys.argv) < 4):
    print "Invalid number of arguments (expected 2)"
    quit();

outputName = sys.argv[2];
filteredCountryName = sys.argv[3];

# get config
with open('config.json') as config_info:
    configData = json.load(config_info);
    apiKey = configData["apikey"];
    infodbKey = configData["otherapikey"];

print "Getting Transactions from ", str(sys.argv[1]);

with open(sys.argv[1]) as json_data:
    blockData = json.load(json_data);

outputFile = open(outputName, 'w');

def getTotalOutValue (out):
    val = 0;
    for i in range(0, len(out)):
        val = val + out[i]['value'];
    return val;

print "Reading data from %d Blocks" % len(blockData['blocks']);
for i in range(0, len(blockData['blocks'])):
    blockHeight = blockData['blocks'][i]['hash'];

    url = 'https://blockchain.info/rawblock/' + str(blockHeight) + '?format=json&api_code=' + apiKey;
    response = requests.get(url)

    block = json.loads(response.text);

    for x in range(0, len(block['tx'])):
        tx = block['tx'][x];

        relayIP = tx['relayed_by'];

        if (relayIP == '127.0.0.1'):
            continue;

        outputAmount = getTotalOutValue(tx['out']);

        try:
            # Retrieve the about that IP (including country) from this nifty API
            httpPacket = requests.get("http://api.ipinfodb.com/v3/ip-country/?key=" + str(infodbKey) + "&ip=" + relayIP, timeout=None)

            # If the requests to the server fails, we wait 1 second (for rate limiting) and try again
            if (httpPacket.status_code != 200):
                time.sleep(20);
                httpPacket = requests.get("http://api.ipinfodb.com/v3/ip-country/?key=" + str(infodbKey) + "&ip=" + relayIP, timeout=None)
        except:
            print "Fatal Error Getting Packet, Skipping ... "
            time.sleep(5); #sleep for a few seconds if we fail.
            continue;

        try:
            countryName = (httpPacket.text.split(";")[4])
        except IndexError:
            countryName = ""

        if (countryName.lower() == filteredCountryName.lower()):
            outputFile.write("%s, %d, %d, %d, %d, %s, %s, %d\n" % (tx['hash'], block['time'], tx['vin_sz'], tx['vout_sz'], tx['size'], tx['relayed_by'], tx['tx_index'], outputAmount))

    print "%d%% Complete" % ((i*100)/len(blockData['blocks']));
