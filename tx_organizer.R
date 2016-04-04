# Authors:
# Christopher Jennison
# Ross Sbriscia

library(ggplot2)
library(RColorBrewer)
require(scales)
library(grid)
library(dplyr)

country <- "Ukraine"

df <- read.csv("./transaction_Data/tx_dump.json", header = FALSE)
colnames(df) <- c("hash", "date", "vin_sz", "vout_sz", "size", "relayed_by", "tx_index", "out_amount")

df$date <- as.Date(as.POSIXct(df$date, origin="1970-01-01"))
df$out_amount <- df$out_amount/100000000

# First graph: Number of Transaction on Each Day (Histogram)
# Second Graph: Amount of money on each day

# Preparation
byDate <- group_by(df, date)
outputByDate <- summarize(byDate, out_amount=sum(out_amount), numTransactions=n())

# Number of Transactions
ggplot(data=outputByDate, aes(x=date, y=numTransactions)) + geom_bar(stat="identity") + 
  theme_minimal() + xlab("Dates") + ylab("Number of Transactions") + ggtitle(paste("Transactions from 2013 to Present in", country))
ggsave(paste("TransactionTimelinePlot_", country, ".png", sep=""), width=10, height=6)

# Amount of Money spent per day
ggplot(data=outputByDate, aes(x=date, y=out_amount)) + geom_line() + scale_fill_brewer(palette="Blues") + scale_y_continuous(labels=comma) +
  theme_minimal() + xlab("Dates") + ylab("Amount of Bitcoin Sent") + ggtitle(paste("Amount of Bitcoin used from 2013 to Present in", country))
ggsave(paste("OutputTimelinePlot_", country, ".png", sep=""), width=10, height=6)


MainPlot <- ggplot() + geom_bar(data=outputByDate, aes(x=date, y=numTransactions), stat="identity") + theme_minimal() + xlab("Dates") + ylab("Number of Transactions") + ggtitle(paste("Transactions from 2013 to Present in", country))
SecondaryPlot <- ggplot() + geom_line(data=outputByDate, aes(x=date, y=out_amount)) + scale_y_continuous(labels=comma) + theme_minimal() + xlab("Dates") + ylab("Amount of Bitcoin Sent") + ggtitle(paste("Amount of Bitcoin used from 2013 to Present in", country))

pdf(paste("TX_Output_Combined_", country, ".pdf", sep=""))
grid.newpage()
grid.draw(rbind(ggplotGrob(MainPlot), ggplotGrob(SecondaryPlot), size = "last"))
dev.off()

