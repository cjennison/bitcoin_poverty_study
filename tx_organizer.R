print("Loading JSON File ... ")

df <- read.csv("./transaction_Data/russia1.csv", header = FALSE)
colnames(df) <- c("hash", "date", "vin_sz", "vout_sz", "size", "relayed_by", "tx_index", "out_amount")

df$date <- as.POSIXct(df$date, origin="1970-01-01")
df$out_amount <- df$out_amount/1000000