import requests
from datetime import datetime

#class Sources(list):
#    #TODO: list of sources

class CollectorRequest:
    def __init__(self, lastRequestTime, sources, country, language, category, sortBy="popularity"):
        self.sortBy = sortBy
        
        # A date and time of the last request. This should be in ISO 8601 format
        # (e.g. 2021-04-26 or 2021-04-26T08:42:21) 
        self.lastRequestTime = lastRequestTime

        # A comma-seperated string of identifiers for the news sources or blogs you want headlines from.
        self.sources = sources
        
        # Possible options: en, ru, etc. Note: you can't mix this param with the sources param.
        self.country = country

        # The 2-letter ISO-639-1 code of the language you want to get 
        # headlines for. Possible options: ar, de, en, es, fr, he, it, 
        # nl, no, pt, ru, se, ud, zh. 
        self.language = language

        # The category you want to get headlines for. Possible options: business,
        # entertainment, general, health, science, sports, technology.
        self.category = category

class Collector:
    def __init__(self, apiKey):
        self.apiKey   = apiKey
        self.payload  = {"apiKey": apiKey}
        self.requests = requests

    # This one is used to search through predefined sources with keywords 
    def getEverything(self, collreq):
        endpoint = "https://newsapi.org/v2/everything"

        self.payload["sources"]  = collreq.sources
        self.payload["sortBy"]   = collreq.sortBy
        self.payload["from"]     = collreq.lastRequestTime
        self.payload["language"] = collreq.language

        response = self.requests.get(endpoint, params=self.payload)
        
        if response.status_code != 200:
            raise BaseException("[ERROR]: Collector: Either server didn't respond or has resulted in zero results.")
        
        try:
            content = response.json()
        except ValueError:
            raise ValueError("[ERROR]: Collector: No json data could be retrieved.")
        
        return content

    # This one returns top headlines in particular country and category
    def getTopHeadlines(self, collreq):
        endpoint = "https://newsapi.org/v2/top-headlines"

        self.payload["country"]  = collreq.country
        self.payload["category"] = collreq.category

        response = self.requests.get(endpoint, params=self.payload)

        if response.status_code != 200:
            raise BaseException("[ERROR]: Collector: Either server didn't respond or has resulted in zero results.")
        
        try:
            content = response.json()
        except ValueError:
            raise ValueError("[ERROR]: Collector: No json data could be retrieved.")
        
        return content