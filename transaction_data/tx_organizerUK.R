# Authors:
# Christopher Jennison
# Ross Sbriscia

# Event Sources:
# http://www.bbc.com/news/world-middle-east-26248275

# Event Categories:
# Political: Any event made as a decision of politicol leadership or voting not with intent of violent force (Elections, Deals)
# Social: Any event caused by social upset or structure (Riots)
# Economic: Events with respect to purely economic means (Banking)
# Military: An event whose intent was purely militaristic (War)

library(ggplot2)
library(RColorBrewer)
require(scales)
library(grid)
library(dplyr)
library(stringr)
library(gridExtra)
library(knitr)

country <- "Ukraine"

temp = list.files(path=paste(getwd(), "/", sep=""), pattern="*.csv")

myfiles = lapply(paste(getwd(), "/", temp, sep=""), read.csv, header = FALSE)
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


events <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O")
types <- c("Social", "Social", "Political", "Military", "Political", "Political", "Social", "Political", "Political", "Economic", "Military", "Political", "Social", "Political", "Political")
eventDescriptions <- c("Police break up protests in Kiev", 
                      "Protestors occupy city hall in Kiev",
                      "Prime Minister Mykola Azarov resigns",
                      "Gov't snipers kill over 100 demonstrators",
                      "Viktor Yanukovych flees Ukraine for Russia",
                      "After a vote of support from the people, Putin signs a law annexing Crimea",
                      "Protestors seize buildings in Eastern Ukraine",
                      "Several Provinces declare intedepdence after referendum",
                      "Petro Poroshenko is elected president of Ukraine",
                      "Gov't signs trade deal increasing ties with EU",
                      "Pro-Russian Rebels shoot down flight MH17",
                      "Minsk Treaty Signed",
                      "Ukrainian Sepratists take Donetsk airport",
                      "Peace talks fail",
                      "Kerry lands in Ukraine")

dates <- c(as.Date("2013-11-10"),
           as.Date("2013-12-1"),
           as.Date("2014-01-28"),
           as.Date("2014-02-20"),
           as.Date("2014-02-22"),
           as.Date("2014-03-16"),
           as.Date("2014-04-7"),
           as.Date("2014-05-11"),
           as.Date("2014-05-25"),
           as.Date("2014-06-27"),
           as.Date("2014-07-17"),
           as.Date("2014-09-5"),
           as.Date("2015-01-22"),
           as.Date("2015-01-31"),
           as.Date("2015-02-12"))

events_df <- data.frame(events, dates, types, eventDescriptions);

# Number of Transactions
graph <- ggplot(data=outputByDate, aes(x=date, y=numTransactions)) + geom_bar(stat="identity")
graph <- graph + theme_minimal() + xlab("Dates") + scale_x_date(date_breaks = "1 month", date_labels = "%b %d %y")
graph <- graph + ylab("Number of Transactions") + ggtitle(paste("Transactions from 2013 to Present in", country))
graph <- graph + geom_vline(data=events_df, aes(xintercept=as.numeric(as.Date(events_df$dates)), colour=events_df$types), linetype=4)
graph <- graph + geom_text(data=events_df, aes(x=events_df$dates + 4, y=max(outputByDate$numTransactions, na.rm=TRUE), label=events, colour=types)) + scale_colour_discrete(name="Event Type")+ theme(axis.text.x = element_text(angle = 45, hjust = .5))
graph
ggsave(paste("../outputs/TransactionTimelinePlot_", country, ".png", sep=""), width=20, height=6)

# Amount of Money spent per day
graph <- ggplot(data=outputByDate, aes(x=date, y=out_amount,)) + geom_line() + scale_fill_brewer(palette="Blues") + scale_y_continuous(labels=comma) +coord_cartesian(ylim = c(0, 200000)) 
  graph <- graph + theme_minimal() + scale_x_date(date_breaks = "1 month", date_labels = "%b %d %y") + xlab("Dates") + ylab("Total Bitcoin Sent")
  graph <- graph + ggtitle(paste("Amount of Bitcoin used from 2013 to Present in", country))
  graph <- graph +  geom_vline(data=events_df, aes(xintercept=as.numeric(as.Date(events_df$dates)), colour=events_df$types), linetype=4)
  graph <- graph +  geom_text(data=events_df, aes(x=events_df$dates + 4, y=max(outputByDate$out_amount, na.rm=TRUE), label=events, colour=types)) + scale_colour_discrete(name="Event Type")+ theme(axis.text.x = element_text(angle = 45, hjust = .5))
graph
ggsave(paste("../outputs/OutputTimelinePlot_", country, ".png", sep=""), width=20, height=6)

# Amount of Money spent per day
graph <- ggplot(data=outputByDate, aes(x=date, y=out_amount,)) + geom_line() + scale_fill_brewer(palette="Blues") + scale_y_continuous(labels=comma)
graph <- graph + theme_minimal() + scale_x_date(date_breaks = "1 month", date_labels = "%b %d %y") + xlab("Dates") + ylab("Total Bitcoin Sent")
graph <- graph + ggtitle(paste("Amount of Bitcoin used from 2013 to Present in", country))
graph <- graph +  geom_vline(data=events_df, aes(xintercept=as.numeric(as.Date(events_df$dates)), colour=events_df$types), linetype=4)
graph <- graph +  geom_text(data=events_df, aes(x=events_df$dates + 4, y=max(outputByDate$out_amount, na.rm=TRUE), label=events, colour=types)) + scale_colour_discrete(name="Event Type")+ theme(axis.text.x = element_text(angle = 45, hjust = .5))
graph
ggsave(paste("../outputs/OutputTimelinePlotNoCutoff_", country, ".png", sep=""), width=20, height=6)


# Avg Amount of Money Spent per day
ggplot() + geom_line(data=outputByDate, aes(x=date, y=mean_output)) + theme_minimal()  + scale_x_date(date_breaks = "1 month", date_labels = "%b %d %y") + scale_y_continuous(labels=comma) + 
  theme_minimal() + xlab("Dates") + ylab("Avg Amount of Bitcoin Sent") + ggtitle(paste("Avg Amount of Bitcoin sent per day from 2013 to Present in", country)) + 
  geom_vline(aes(xintercept=as.numeric(as.Date(events_df$dates)), colour=events_df$types), linetype=4) + 
  geom_text(data=events_df, aes(x=events_df$dates + 4, y=max(outputByDate$mean_output, na.rm=TRUE), label=events, colour=types)) + scale_colour_discrete(name="Event Type")+ theme(axis.text.x = element_text(angle = 45, hjust = .5))
  
ggsave(paste("../outputs/AvgOutputTimelinePlot_", country, ".png", sep=""), width=20, height=6)
 
#Print Events
pdf("../outputs/event_key.pdf", height=8.5, width=14)
grid.table(events_df)
dev.off()

