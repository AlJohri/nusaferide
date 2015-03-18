library("dplyr")
library("ggplot2")
library("scales")

tweets = read.csv("tweets.csv", header=TRUE)

tweets$date = as.Date(tweets$X_timestamp)
tweets$timestamp = as.POSIXct(tweets$X_timestamp)
tweets$hour = as.POSIXlt(tweets$X_timestamp)$hour
tweets$minute = as.POSIXlt(tweets$X_timestamp)$min
tweets$wday = as.POSIXlt(tweets$X_timestamp)$wday
tweets$year = as.POSIXlt(tweets$X_timestamp)$year + 1900
tweets$month_num = as.POSIXlt(tweets$X_timestamp)$mon

tweets$day = as.Date(cut(tweets$date, breaks = "day"))
tweets$month = as.Date(cut(tweets$date, breaks = "month"))
tweets$week = as.Date(cut(tweets$date, breaks = "week"))

# 
# tweets$weeknum = as.numeric( format(tweets$date+3, "%U"))

tweets <- filter(tweets, avg_time = !is.na(avg_time))
tweets <- filter(tweets, avg_time = !is.infinite(avg_time))
# tweets <- filter(tweets, avg_time = avg_time != 0)

tweets$hour[tweets$hour== 18 & tweets$minute > 50] <- 19
tweets$hour[tweets$hour== 0] <- 24
tweets$hour[tweets$hour== 1] <- 25
tweets$hour[tweets$hour== 2] <- 26

tweets$acayear <- NA
tweets$acayear[c(tweets$date > "2012-09-20" & tweets$date < "2013-06-21")] <- "2012-2013"
tweets$acayear[c(tweets$date > "2013-09-16" & tweets$date < "2014-06-20")] <- "2013-2014"
tweets$acayear[c(tweets$date > "2014-09-15" & tweets$date < "2015-06-19")] <- "2014-2015"

# Average wait time by month over time from 2012-2015
ggplot(tweets, aes(x = month, y = avg_time, color=acayear)) + stat_summary(fun.dat = mean_se, geom='pointrange') + stat_summary(fun.dat = mean_se, geom='line') + scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) + theme(legend.position='bottom')

# Distribution of wait times through the day
ggplot(tweets, aes(x = hour, y = avg_time)) + stat_summary(fun.dat = mean_se) + scale_x_continuous(breaks=seq(from = 18, to = 27, by = 1))

# Distribution of wait times throughout the day during different days of the week
ggplot(tweets, aes(x = hour, y = avg_time)) + stat_summary(fun.dat = mean_se) + scale_x_continuous(breaks=seq(from = 18, to = 27, by = 1)) + facet_wrap(~ wday)

# Distribution of wait times throughout the day during different months of the year
ggplot(tweets, aes(x = hour, y = avg_time)) + stat_summary(fun.dat = mean_se) + scale_x_continuous(breaks=seq(from = 18, to = 27, by = 1)) + facet_wrap(~ month_num)

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