from __future__ import division

import re, datetime
from models import tweets

def average(x): return sum(x)/len(x)

# https://regex101.com/r/mC0nC6/1

text_to_time = {
	"1 hour": 60,
	"an hour": 60,
	"half an hour": 30,
	"half hour": 30,
	"twenty": 20,
	"thirty": 30,
	"forty": 40,
	"fifty": 50
}

spam_regex = re.compile(r"Just a reminder to all SafeRide users|Heads-up to all SafeRide users|Just a reminder SafeRide riders|Hey SafeRide peeps|SafeRide service suspended|Testing")
open_regex = re.compile(r"(open!)|(open for)|(we're open)|(are open)", re.I)
booked_regex = re.compile(r"(overbooked)|(booked)|(last call)|(last rides)|(couple rides)", re.I)
single_numeric_time_regex = re.compile(r"(^\d\d)$|(\d{1,2}) min|(\d{1,2})m|about (\d{1,2})|still (\d{1,2})|around (\d{1,2})|over (\d{1,2})|(\d{1,2}) still|still at (\d{1,2})|up to (\d{1,2})|down to (\d{1,2})", re.I)
single_text_time_regex = re.compile(r"(twenty) minute|(thirty) minute|(forty) minute|(fifty) minute|still (an hour)|still (thirty)|over (an hour)|around (an hour)|a (half hour)|more than (an hour)|about (an hour)|^(1 hour)$|around (half an hour)|is (an hour)", re.I)
numeric_time_range_regex = re.compile(r"(?:(\d{1,2})(?:\s+)?-(?:\s+)?(\d{1,2}))|(?:(\d{1,2})(?:\s+)?to(?:\s+)?(\d{1,2}))")
text_time_range_regex = re.compile(r"(\d{1,2}) to (an hour)|(\d{1,2}) to (1 hour)")
tapride_with_phone_single_time_regex = re.compile(r"phone(?:\s+)?(?:-)?(?:\s+)?(\d{1,2}), tapride(?:\s+)?(?:-)?(?:\s+)?(\d{1,2})|tapride(?:\s+)?(?:-)?(?:\s+)?(\d{1,2}), phone(?:\s+)?(?:-)?(?:\s+)?(\d{1,2})", re.I)
# re.compile(r"(half hour)|(thirty)|(1 hour)|(1 hr)|(an hour)|(one hour)", re.I)

for tweet in tweets.find().sort("_id", -1):
	if spam_regex.search(tweet['text']):
		tweet['spam'] = True
		tweets.save(tweet)
		continue
	else:
		tweet['spam'] = False
		tweets.save(tweet)

	match = booked_regex.search(tweet['text'])
	if match:
		tweet['avg_time'] = float("inf")
		print tweet['_timestamp'].strftime('%Y-%m-%d %H:%M:%S'), tweet['avg_time']
		tweets.save(tweet)
		continue

	match = open_regex.search(tweet['text'])
	if match:
		tweet['avg_time'] = 0
		print tweet['_timestamp'].strftime('%Y-%m-%d %H:%M:%S'), tweet['avg_time']
		tweets.save(tweet)
		continue

	match = tapride_with_phone_single_time_regex.search(tweet['text'])
	match = match or numeric_time_range_regex.search(tweet['text'])
	match = match or text_time_range_regex.search(tweet['text'])
	match = match or single_numeric_time_regex.search(tweet['text'])
	match = match or single_text_time_regex.search(tweet['text'])
	if match:
		times_raw = [time.lower() for time in match.groups() if time is not None]
		times = [text_to_time[time] if not time.isdigit() else time for time in times_raw]
		times = [int(time) for time in times]
		tweet['avg_time'] = average(times)
		print tweet['_timestamp'].strftime('%Y-%m-%d %H:%M:%S'), tweet['avg_time']
		tweets.save(tweet)
		continue

manual_spam_list = [382640614585532417, 270988203908005888, 295650183721656320, 420665538130358272]

for tweet_id in manual_spam_list:
	tweet = tweets.find_one({"_id": tweet_id})
	tweet['spam'] = True
	tweets.save(tweet)

