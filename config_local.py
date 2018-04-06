import os
from collections import defaultdict
import secrets

DEBUG = True

SECRET_KEY = os.getenv('SECRET_KEY', secrets.token_urlsafe(128))

# Only set this to http if you have ssl set up.
SCHEME = os.getenv("SERVER_SCHEME", "http")
PREFERRED_URL_SCHEME = os.getenv("SERVER_SCHEME", "http")

# This must be the url you are requesting at or you'll get 404 errors.
SERVER_NAME = os.getenv('SERVER_DOMAIN', 'localhost')

# This must be accurate as well or the same as above. This defaults to 5001 WHICH IS WRONG.
PILLAR_SERVER_ENDPOINT = os.getenv('SERVER_SCHEME', 'http') + '://' + SERVER_NAME + '/api/'

# Not sure about these, but this was working for me.
PORT = 80
HOST = '0.0.0.0'

# os.environ['OAUTHLIB_INSECURE_TRANSPORT'] = 'true'
os.environ['PILLAR_MONGO_DBNAME'] = 'flamenco'
os.environ['PILLAR_MONGO_PORT'] = '27017'
os.environ['PILLAR_MONGO_HOST'] = 'mongo'

CACHE_TYPE = 'redis'  # null
CACHE_KEY_PREFIX = 'pw_'
CACHE_REDIS_HOST = 'redis'
CACHE_REDIS_PORT = '6379'
CACHE_REDIS_URL = 'redis://redis:6379'

# MUST be 8 characters long, see pillar.flask_extra.HashedPathConverter
# STATIC_FILE_HASH = '12345678'
# The value used in production is appended from Dockerfile.
STATIC_FILE_HASH = 'sxRfl2j5'
