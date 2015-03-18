from pymongo import MongoClient
client = MongoClient()
db = client.nusaferide
tweets = db.tweets