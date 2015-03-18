import requests, lxml.html, datetime
from models import tweets

screen_name = "NUSafeRide"

cursor = str(999999999999999999)
base_url = "https://twitter.com/i/profiles/show/%s/timeline?" % screen_name

# list(tweets.find().sort("_id", -1).limit(1))
# list(tweets.find().sort("_id", 1).limit(1))
# cursor = str(555545613027508224)

# reverse chronological order

while True:
    data = requests.get(base_url + "&max_id=" + str(cursor)).json()
    doc = lxml.html.fromstring(data['items_html'])
    root_containers = doc.cssselect(".ProfileTweet") # new style twitter profile
    root_containers = root_containers or doc.cssselect(".js-stream-tweet") # old style twitter profile

    if not root_containers:
        import pdb; pdb.set_trace()
        break

    for container in root_containers:
        if container.get('data-retweet-id'): continue # ignore retweets
        tweet_id = container.get('data-tweet-id')
        text_container = container.cssselect('.js-tweet-text')
        timestamp_container = container.cssselect('.js-short-timestamp')
        if not tweet_id and not text_container and not timestamp_container: continue
        text_container = text_container[0]
        timestamp_container = timestamp_container[0]

        tweet = {
            "_id": long(tweet_id),
            "_timestamp": datetime.datetime.fromtimestamp(float(timestamp_container.get('data-time'))),
            "text": text_container.text.encode('utf-8','ignore') if text_container.text else ""
        }

        print tweet['_id'], tweet['_timestamp']

        tweets.save(tweet)

    cursor = data["max_id"]
    print cursor
