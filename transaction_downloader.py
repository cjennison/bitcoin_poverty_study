import sys
import json
import requests
import time

if (len(sys.argv) < 4):
    print "Invalid number of arguments (expected 4)"
    quit();

outputName = sys.argv[2];
filteredCountryName = sys.argv[3];

checkedIPs = {};

# get config
with open('config.json') as config_info:
    configData = json.load(config_info);
    apiKey = configData["apikey"];
    infodbKey = configData["otherapikey"];

print "Getting Transactions from ", str(sys.argv[1]);

with open(sys.argv[1]) as json_data:
    blockData = json.load(json_data);

outputFile = open(outputName, 'w');
logfile = open(filteredCountryName + ".log", 'w');

def getTotalOutValue (out):
    val = 0;
    for i in range(0, len(out)):
        val = val + out[i]['value'];
    return val;

print "Reading data from %d Blocks" % len(blockData['blocks']);
for i in range(0, len(blockData['blocks'])):
    blockHeight = blockData['blocks'][i]['hash'];

    try:
        url = 'https://blockchain.info/rawblock/' + str(blockHeight) + '?format=json&api_code=' + apiKey;
        response = requests.get(url)
        block = json.loads(response.text);
    except:
        print "Error getting Tx for Block"
        time.sleep(5)
        continue;

    for x in range(0, len(block['tx'])):
        tx = block['tx'][x];

        relayIP = tx['relayed_by'];

        if (relayIP == '127.0.0.1' or checkedIPs.has_key(relayIP)):
            continue;

        print "New IP ... Checking ..."

        outputAmount = getTotalOutValue(tx['out']);

        try:
            # Retrieve the about that IP (including country) from this nifty API
            httpPacket = requests.get("http://api.ipinfodb.com/v3/ip-country/?key=" + str(infodbKey) + "&ip=" + relayIP, timeout=None)

            # If the requests to the server fails, we wait 1 second (for rate limiting) and try again
            if (httpPacket.status_code != 200):
                print "Failure getting IP Info .. Waiting 2 Seconds"
                time.sleep(2);
                httpPacket = requests.get("http://api.ipinfodb.com/v3/ip-country/?key=" + str(infodbKey) + "&ip=" + relayIP, timeout=None)
        except:
            print "Fatal Error Getting Packet, Skipping ... "
            time.sleep(5); #sleep for a few seconds if we fail.
            continue;

        try:
            countryName = (httpPacket.text.split(";")[4])
        except IndexError:
            countryName = ""

        countryName = countryName.replace(" ", "");

        if (countryName.lower() == filteredCountryName.lower()):
            print "Matching IP!"
            outputFile.write("%s, %d, %d, %d, %d, %s, %s, %d\n" % (tx['hash'], block['time'], tx['vin_sz'], tx['vout_sz'], tx['size'], tx['relayed_by'], tx['tx_index'], outputAmount))
        else:
            checkedIPs[relayIP] = True;
            print "Bad IP, Adding to skip list"

    print "%d%% Complete %d/%d" % ((i*100)/len(blockData['blocks']), i, len(blockData['blocks']));
    logfile.write("%d%% Complete\n" % ((i*100)/len(blockData['blocks'])))

logfile.write("Completed!");
