import requests
import json
from datetime import datetime, date, time, timedelta

startYear = 2013
startDay = 1;
startMonth = 1;

numberOfDays = 1;

data = {
    'blocks': list()
}

# Source; http://stackoverflow.com/questions/6999726/how-can-i-convert-a-datetime-object-to-milliseconds-since-epoch-unix-time-in-p
date = datetime(startYear, startDay, startMonth)
epoch = datetime.utcfromtimestamp(0)

def unix_time_millis(dt):
    return int((dt - epoch).total_seconds())*1000

print "Downloading Blockchain Data from Blockchain.info from " + str(date) + " for " + str(numberOfDays) + " days";

for i in range(0, numberOfDays):
    date += timedelta(days=1);

    #url = 'https://blockchain.info/rawtx/129728510'

    # get blocks on this day
    url = 'https://blockchain.info/blocks/' + str(unix_time_millis(date)) + '?format=json'
    response = requests.get(url)

    blocks = json.loads(response.text)['blocks'];
    for k in range(0, len(blocks)):
        data['blocks'].append(blocks[k]);

with open('block_requests/blocks_for_' + str(startYear) + '_' + str(startMonth) + '_' + str(startDay) + '__' + str(numberOfDays) + '_days_.json', 'w') as outfile:
    json.dump(data, outfile);
