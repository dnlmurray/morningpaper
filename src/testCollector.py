from collector import Collector
from collector import CollectorRequest
from datetime import datetime

def testTopHeadlinesRequest(apiKey, collreq):
    collector = Collector(apiKey)
    content = collector.getTopHeadlines(collreq)

def testEverythingRequest(apiKey, collreq):
    collector = Collector(apiKey)
    content = collector.getEverything(collreq)

def testMain(apiKey):
    collreq = CollectorRequest(lastRequestTime="2021-04-25", sources="the-washington-post, bbc, forbes", country="us", language="en", category="general")
    
    testTopHeadlinesRequest(apiKey, collreq)
    testEverythingRequest(apiKey, collreq)

    # No exceptions = success?
    print("Success!")

if __name__ == "__main__":
    success = testMain("5d2bf1b078c34e2aa7257b36c542d11d")
