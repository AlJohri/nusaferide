import unicodecsv as csv
from models import tweets

fieldnames = ["_id", "_timestamp", "avg_time", "text"]

with open("tweets.csv", "w") as f:
	writer = csv.DictWriter(f, fieldnames = fieldnames)
	writer.writeheader()
	for tweet in tweets.find().sort("_id", -1):
		if tweet['spam']: continue
		d = {k:v for k,v in tweet.iteritems() if k in fieldnames}
		d['_id'] = "'" + str(d['_id'])  + "'" # 18 digit number too big for everyone
		writer.writerow(d)