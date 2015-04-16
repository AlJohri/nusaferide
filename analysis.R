library("dplyr")
library("ggplot2")
library("scales")
library("tidyr")
# library("RJSONIO")
# library("rjson")
library(df2json)

library(ggthemes)

require(reshape2)

tweets = read.csv("tweets.csv", header=TRUE)

tweets$date = as.Date(tweets$X_timestamp)
tweets$timestamp = as.POSIXct(tweets$X_timestamp)
tweets$hour = as.POSIXlt(tweets$X_timestamp)$hour
tweets$minute = as.POSIXlt(tweets$X_timestamp)$min
tweets$wday = as.POSIXlt(tweets$X_timestamp)$wday
tweets$year = as.POSIXlt(tweets$X_timestamp)$year + 1900
tweets$month_num = as.POSIXlt(tweets$X_timestamp)$mon

tweets$acayear <- NA
tweets$acayear[c(tweets$date >= "2012-09-20" & tweets$date <= "2013-06-21")] <- "2012-2013"
tweets$acayear[c(tweets$date >= "2013-09-16" & tweets$date <= "2014-06-20")] <- "2013-2014"
tweets$acayear[c(tweets$date >= "2014-06-21" & tweets$date <= "2014-09-14")] <- "Summer 2014"
tweets$acayear[c(tweets$date >= "2014-09-15" & tweets$date <= "2015-06-19")] <- "2014-2015"

tweets$day = as.Date(cut(tweets$date, breaks = "day"))
tweets$month = as.Date(cut(tweets$date, breaks = "month"))
tweets$week = as.Date(cut(tweets$date, breaks = "week"))

# tweets$weeknum = as.numeric( format(tweets$date+3, "%U"))

tweets <- filter(tweets, spam == "False")
tweets <- filter(tweets, avg_time = !is.na(avg_time))
tweets <- filter(tweets, avg_time = !is.infinite(avg_time))
# tweets <- filter(tweets, avg_time = avg_time != 0)

tweets$hour[tweets$hour== 18 & tweets$minute > 50] <- 19
tweets$hour[tweets$hour== 0] <- 24
tweets$hour[tweets$hour== 1] <- 25
tweets$hour[tweets$hour== 2] <- 26

# Average wait time by month over time from 2012-2015
ggplot(tweets, aes(x = month, y = avg_time, color=acayear)) + 
  stat_summary(fun.dat = mean_se, geom='pointrange') + 
  stat_summary(fun.dat = mean_se, geom='line') + 
  scale_x_date(breaks = date_breaks("months"), labels = date_format("%b%y")) + 
  theme(legend.position='bottom') + theme_hc() + scale_colour_hc() + 
  ggtitle("Safe Ride Wait Times") +
  ylab("Average Wait Time") +
  xlab("Month")

graph1csv = tweets[c("month", "avg_time", "acayear")]
graph1csv$month <- as.character(graph1csv$month)
exportJson <- df2json(graph1csv)
write(exportJson, "nbn/app/data/graph1.json")

# graph1csv = tweets[c("X_id","month", "avg_time", "acayear")]
# graph1csv <- dcast(graph1csv, X_id+month+avg_time ~ acayear, value.var='acayear', fill='')
# graph1csv$X_id <- NULL
write.csv(graph1csv, "nbn/app/data/graph1.csv", row.names=FALSE)

# Distribution of wait times through the day
ggplot(tweets, aes(x = factor(hour), y = avg_time)) + stat_summary(fun.dat = mean_se, geom='pointrange') + scale_x_discrete(labels=c("7 PM","8 PM","9 PM","10 PM","11 PM","12 AM","1 AM","2 AM")) + xlab("hour")# seq(from = 18, to = 27, by = 1)

# Distribution of wait times throughout the day during different days of the week
ggplot(tweets, aes(x = hour, y = avg_time)) + stat_summary(fun.dat = mean_se) + scale_x_continuous(breaks=seq(from = 18, to = 27, by = 1)) + facet_wrap(~ wday)

# Distribution of wait times throughout the day during different months of the year
ggplot(tweets, aes(x = hour, y = avg_time)) + stat_summary(fun.dat = mean_se) + scale_x_continuous(breaks=seq(from = 18, to = 27, by = 1)) + facet_wrap(~ month_num)

# Distribution of wait times through the day during different years.
ggplot(filter(tweets, !is.na(acayear)), aes(x = hour, y = avg_time)) + stat_summary(fun.dat = mean_se) + scale_x_continuous(breaks=seq(from = 18, to = 27, by = 1)) + facet_wrap(~ acayear)

summary(filter(tweets, acayear == "2012-2013")$avg_time)
# Min.   1st Qu.  Median    Mean    3rd Qu.   Max. 
# 0.00   20.00    35.00     33.34   45.00     70.00 
summary(filter(tweets, acayear == "2013-2014")$avg_time)
# Min.  1st Qu.   Median    Mean    3rd Qu.    Max. 
# 0.00   20.00    35.00     33.16   45.00      75.00 
summary(filter(tweets, acayear == "2014-2015")$avg_time)
# Min.   1st Qu.  Median    Mean    3rd Qu.    Max. 
# 0.00   20.00    30.00     29.42   40.00      70.00 

# Comparre Average Wait Times in February (busiest month)
summary(tweets[c(tweets$month_num == 1 & tweets$acayear == "2012-2013"),]$avg_time)
summary(tweets[c(tweets$month_num == 1 & tweets$acayear == "2013-2014"),]$avg_time)
summary(tweets[c(tweets$month_num == 1 & tweets$acayear == "2014-2015"),]$avg_time)