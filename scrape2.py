import requests, lxml.html, datetime, time
from models import tweets

s = requests.Session()
s.headers = { 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36' }

start = time.time()

screen_name = "NUSafeRide"

# since = "2015-01-1"
# until = "2015-12-31"
# base_url = "https://twitter.com/i/search/timeline?q=from:%s since:%s until:%s"

until = "09-24-2012" # datetime.datetime.now().strftime("%Y-%m-%d")
base_url = "https://twitter.com/i/search/timeline?q=from:%s until:%s"

cursor = ""

while True:
    url = base_url % (screen_name, until)
    url += "&src=typd"
    url += "&f=realtime"
    url += "&last_note_ts=" + str(int(time.time() - start))
    if cursor: url += "&scroll_cursor=" + cursor
    print url
    data = s.get(url).json()
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

    cursor = data['scroll_cursor']