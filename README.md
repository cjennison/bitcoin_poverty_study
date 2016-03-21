# Bitcoin Poverty Study
A repository to study and understand the impact of Bitcoin on companies with poor economies.  
## Steps:
1. Get all blocks between a given date
2. Get all transactions from each block
3. Using each IP from `relayed_by`, find the associated country that the sender sent the `inv` message from.
4. If the sender is from `COUNTRY_NAME` then add their transaction to the country listing.
5. Do *Statistics*

### Notes:
- **There is no consistent naming enforced. Math at your own risk.**
- These are `RELAYED TRANSACTIONS`. There is no proof that the transactions actually originated from these areas.

# Installation:

Install Pip (http://www.python-requests.org/en/latest/user/install/#install)
```pip install requests```

# Usage:
Run `cp config_tmpl.json config.json` and edit the config file with the supplied API key.

First in `blocks_downloader.py` define the date range you want to examine setting startYear, startMonth, and startDay with numberOfDays greater than 0.  
(ex. 2010, 1, 1 and 365 days will get you a range from 2010 to 2011)  

A file named after your request will appear under `./block_requests`  

Then run the `transaction_downloader.py` with the name of your block list and an output file name  
(ex. `python transaction_downloader.py block_requests/blocks_for_yesterday.json transaction_data/tx_dump_1.json`)
