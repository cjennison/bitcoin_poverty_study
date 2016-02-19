import requests
import json

print "Downloading Data from Blockchain.info"

url = 'https://blockchain.info/rawtx/129728510'
response = requests.get(url)

print response.text
