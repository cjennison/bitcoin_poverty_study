import requests
import json
from datetime import datetime, date, time, timedelta

startYear = 2009
startDay = 1;
startMonth = 9;

numberOfDays = 1;

# Source; http://stackoverflow.com/questions/6999726/how-can-i-convert-a-datetime-object-to-milliseconds-since-epoch-unix-time-in-p
date = datetime(startYear, startDay, startMonth)
epoch = datetime.utcfromtimestamp(0)

def unix_time_millis(dt):
    return int((dt - epoch).total_seconds())*1000

print "Downloading Data from Blockchain.info"


for i in range(0, 1):
    date += timedelta(days=1);

    #url = 'https://blockchain.info/rawtx/129728510'

    # get blocks on this day
    url = 'https://blockchain.info/blocks/' + str(unix_time_millis(date)) + '?format=json'
    response = requests.get(url)
    print response.text
