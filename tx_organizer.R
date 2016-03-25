print("Loading JSON File ... ")

df <- read.csv("./transaction_Data/2013_to_2014_tx_france.csv", header = FALSE)
colnames(df) <- c("hash", "date", "vin_sz", "vout_sz", "size", "relayed_by", "tx_index", "out_amount")

df$date <- as.POSIXct(df$date, origin="1970-01-01")