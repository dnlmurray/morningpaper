import json

class NewsEntity:
    def __init__(self, title, description, source, url):
        self.title       = title
        self.description = description
        self.source      = source
        self.url         = url

    def dbgPrint(self):
        print(" ")
        print(self.title)
        print(self.description)
        print(self.source)
        print(self.url)


def decomposeApiOutput(apiOutput):
    totalResults = int(apiOutput['totalResults'])
    articles     = apiOutput['articles']
    
    decomposedApiOutput = []
    for article in articles:
        entity = NewsEntity(article['title'], article['description'], article['source']['name'], article['url'])
        decomposedApiOutput.append(entity)
    
    return totalResults, decomposedApiOutput

def dbgPrint(decomposedApiOutput):
    for entity in decomposedApiOutput:
        entity.dbgPrint()
        print("------------------------------------------------------------------------")