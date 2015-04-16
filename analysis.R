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

ggplot(tweets, aes(x = date, y = avg_time, color=acayear)) + 
  geom_line() + 
  geom_point() +
  scale_x_date(breaks = date_breaks("months"), labels = date_format("%b%y"))

# Average wait time by month over time from 2012-2015
ggplot(tweets, aes(x = month, y = avg_time, color=acayear)) + 
  stat_summary(fun.dat = mean_se, geom='pointrange') + 
  stat_summary(fun.dat = mean_se, geom='line') + 
  scale_x_date(breaks = date_breaks("months"), labels = date_format("%b%y")) + 
  ggtitle("Safe Ride Wait Times") +
  ylab("Average Wait Time") +
  xlab("Month") +
  theme(legend.position='bottom') + theme_hc() + scale_colour_hc()

# Distribution of wait times through the day
ggplot(tweets, aes(x = factor(hour), y = avg_time)) + stat_summary(fun.dat = mean_se, geom='pointrange') + 
  scale_x_discrete(labels=c("7 PM","8 PM","9 PM","10 PM","11 PM","12 AM","1 AM","2 AM")) + 
  ggtitle("Average Hourly Safe Ride Wait Times") +
  ylab("Average Wait Time") +
  xlab("Hour") +
  theme(legend.position='bottom') + theme_hc() + scale_colour_hc()

# Distribution of wait times throughout the day during different days of the week
ggplot(tweets, aes(x = hour, y = avg_time)) + stat_summary(fun.dat = mean_se) + scale_x_continuous(breaks=seq(from = 18, to = 27, by = 1)) + facet_wrap(~ wday)

# Distribution of wait times throughout the day during different months of the year
ggplot(tweets, aes(x = hour, y = avg_time)) + stat_summary(fun.dat = mean_se) + scale_x_continuous(breaks=seq(from = 18, to = 27, by = 1)) + facet_wrap(~ month_num)

# Distribution of wait times through the day during different years.
ggplot(filter(tweets, !is.na(acayear)), aes(x = factor(hour), y = avg_time)) + 
  stat_summary(fun.dat = mean_se) + facet_wrap(~ acayear) + 
  scale_x_discrete(labels=c("7 PM","8 PM","9 PM","10 PM","11 PM","12 AM","1 AM","2 AM")) + 
  ggtitle("Average Hourly Safe Ride Wait Times by Year") +
  ylab("Average Wait Time") +
  xlab("Hour") +
  theme(legend.position='bottom') + theme_hc() + scale_colour_hc()

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

graph1csv = tweets[c("timestamp", "avg_time", "acayear")]
names(graph1csv) <- c("timestamp", "wait_time", "acayear")
graph1csv$timestamp <- as.character(graph1csv$timestamp)
exportJson <- df2json(graph1csv)
write(exportJson, "nbn/app/data/graph1.json")
write.csv(graph1csv, "nbn/app/data/graph1.csv", row.names=FALSE)

graph2csv = tweets[c("hour", "avg_time")]
graph2csv <- graph2csv %>% group_by(hour) %>% 
  summarise(n = n(), mean = mean(avg_time), sd = sd(avg_time)) %>% 
  mutate(se = sd/sqrt(n), lci = mean + qnorm(0.025)*se, uci = mean + qnorm(0.975)*se
)
exportJson <- df2json(graph2csv)
write(exportJson, "nbn/app/data/graph2.json")
write.csv(graph2csv, "nbn/app/data/graph2.csv", row.names=FALSE)

graph3csv = tweets[c("hour", "avg_time", "acayear")]
graph3csv <- graph3csv %>% filter(acayear != "Summer 2014")
graph3csv <- graph3csv %>% group_by(hour, acayear) %>% 
  summarise(n = n(), mean = mean(avg_time), sd = sd(avg_time)) %>% 
  mutate(se = sd/sqrt(n), lci = mean + qnorm(0.025)*se, uci = mean + qnorm(0.975)*se
)
exportJson <- df2json(graph3csv)
write(exportJson, "nbn/app/data/graph3.json")
write.csv(graph3csv, "nbn/app/data/graph3.csv", row.names=FALSE)
