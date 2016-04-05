# Authors:
# Christopher Jennison
# Ross Sbriscia

library(ggplot2)
library(RColorBrewer)
require(scales)
library(grid)
library(dplyr)
library(stringr)

country <- "Russia"

temp = list.files(path=paste(getwd(), "/transaction_data/", sep=""), pattern="*.csv")

myfiles = lapply(paste(getwd(), "/transaction_data/", temp, sep=""), read.csv, header = FALSE)
assign('df',do.call(rbind , myfiles))

df <- unique(df)
na.omit(df)

#df <- read.csv("./transaction_Data/russia1.csv", header = FALSE)
colnames(df) <- c("hash", "date", "vin_sz", "vout_sz", "size", "relayed_by", "tx_index", "out_amount")

df$date <- as.Date(as.POSIXct(df$date, origin="1970-01-01"))
df$out_amount <- df$out_amount/100000000

# First graph: Number of Transaction on Each Day (Histogram)
# Second Graph: Amount of money on each day

# Preparation
byDate <- group_by(df, date)
outputByDate <- summarize(byDate, out_amount=sum(out_amount), 
                                  numTransactions=n(), 
                                  mean_output=(sum(out_amount)/n()))


events <- c("A", "B", "C", "D", "E", "F", "G", "H", "I")
eventDescriptions <- c("Ukrainian peaceful protest in Kiev", 
                      "Protestors occupy city hall in Kiev",
                      "Putin buys $15bn in Ukrainian Debt",
                      "Parliament passes any protest law, riots happen, protestors control city hall",
                      "Prime Minister Mykola Azarov resigns, anti-protest law is annulled",
                      "Arrested protestors are released",
                      "Deadly riot erupts, 88 people die in 24 hours",
                      "Pro-Russian gunmen seize key buildings in the Crimean capital, Simferopol",
                      "Russia authorizes Putin to use force in Ukraine")
dates <- c(as.Date("2013-11-10"), #A
           as.Date("2013-12-02"), #B
           as.Date("2013-12-17"), #C
           as.Date("2014-01-16"), #D
           as.Date("2014-01-28"), #E
           as.Date("2014-02-14"), #F
           as.Date("2014-02-20"), #G
           as.Date("2014-02-28"), #H
           as.Date("2014-03-1"))  
events_df <- data.frame(events, dates, eventDescriptions);

# Number of Transactions
ggplot(data=outputByDate, aes(x=date, y=numTransactions)) + guides(colour=FALSE) + geom_bar(stat="identity") + 
  theme_minimal() + xlab("Dates") + scale_x_date(date_breaks = "1 month", date_labels = "%b %d %y") +  
  ylab("Number of Transactions") + ggtitle(paste("Transactions from 2013 to Present in", country)) + 
  geom_vline(data=events_df, aes(xintercept=as.numeric(as.Date(events_df$dates)), colour=events_df$events), linetype=4) + 
  geom_text(data=events_df, aes(x=events_df$dates + 4, y=max(outputByDate$numTransactions, na.rm=TRUE), label=events, colour=events))

ggsave(paste("outputs/TransactionTimelinePlot_", country, ".png", sep=""), width=20, height=6)

# Amount of Money spent per day
ggplot(data=outputByDate, aes(x=date, y=out_amount)) + geom_line() + guides(colour=FALSE) + scale_fill_brewer(palette="Blues") + scale_y_continuous(labels=comma) +
 theme_minimal() + scale_x_date(date_breaks = "1 month", date_labels = "%b %d %y") + xlab("Dates") + ylab("Total Bitcoin Sent") + 
 ggtitle(paste("Amount of Bitcoin used from 2013 to Present in", country)) +
  geom_vline(data=events_df, aes(xintercept=as.numeric(as.Date(events_df$dates)), colour=events_df$events), linetype=4) + 
  geom_text(data=events_df, aes(x=events_df$dates + 4, y=max(outputByDate$out_amount, na.rm=TRUE), label=events, colour=events))

ggsave(paste("outputs/OutputTimelinePlot_", country, ".png", sep=""), width=20, height=6)

# Avg Amount of Money Spent per day
ggplot() + geom_line(data=outputByDate, aes(x=date, y=mean_output)) + theme_minimal() + guides(colour=FALSE) + scale_x_date(date_breaks = "1 month", date_labels = "%b %d %y") + scale_y_continuous(labels=comma) + 
  theme_minimal() + xlab("Dates") + ylab("Avg Amount of Bitcoin Sent") + ggtitle(paste("Avg Amount of Bitcoin sent per day from 2013 to Present in", country)) + 
  geom_vline(aes(xintercept=as.numeric(as.Date(events_df$dates)), colour=events_df$events), linetype=4) + 
  geom_text(data=events_df, aes(x=events_df$dates + 4, y=max(outputByDate$mean_output, na.rm=TRUE), label=events, colour=events))
  
ggsave(paste("outputs/AvgOutputTimelinePlot_", country, ".png", sep=""), width=20, height=6)
 
# MainPlot <- ggplot() + geom_bar(data=outputByDate, aes(x=date, y=numTransactions), stat="identity") + theme_minimal() + xlab("Dates") + ylab("Number of Transactions") + ggtitle(paste("Transactions from 2013 to Present in", country))
#ggplot() + geom_line(data=outputByDate, aes(x=date, y=out_amount)) + scale_x_date(date_breaks = "1 month", date_labels = "%b %d %y") + scale_y_continuous(labels=comma) + theme_minimal() + xlab("Dates") + ylab("Amount of Bitcoin Sent") + ggtitle(paste("Amount of Bitcoin used from 2013 to Present in", country))

# pdf(paste("TX_Output_Combined_", country, ".pdf", sep=""))
# grid.newpage()
# grid.draw(rbind(ggplotGrob(MainPlot), ggplotGrob(SecondaryPlot), size = "last"))
# dev.off()

