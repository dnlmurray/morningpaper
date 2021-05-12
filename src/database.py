import os
import sys

import sqlalchemy

POSTGRES_USER = os.getenv('POSTGRES_USER')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD')
if not POSTGRES_USER or not POSTGRES_PASSWORD:
    sys.exit('No database credentials were found in ENV')

url = f'postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@localhost/morningpaper'
engine = sqlalchemy.create_engine(url)
