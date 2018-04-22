import logging
import os
import json

from flask import Flask, request
from flask_cors import CORS, cross_origin
import MySQLdb as mdb
from flask_cache import Cache

app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'
app.config['CORS_HEADERS'] = 'Content-Type'
CORS(app)
# cache = Cache(app,config={'CACHE_TYPE': 'simple'})

logging.getLogger('flask_cors').level = logging.DEBUG


# Read PORT available on cloud server
port = int(os.environ.get('PORT', 8000))

# Create a flask app and configure it
app = Flask(__name__)
counter = 1

class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            return float(o)
        return super(DecimalEncoder, self).default(o)

def connect_database():
    try:
        MYSQL_DATABASE_URI="prithvidb.cqlgx6wqa58v.us-west-2.rds.amazonaws.com"
        MYSQL_DATABASE_USER="dfwcrew"
        MYSQL_DATABASE_PASS="HelloWorld"
        MYSQL_DATABASE_SCHEMA="prithvidb"
        con = mdb.connect(MYSQL_DATABASE_URI, MYSQL_DATABASE_USER, \
                      MYSQL_DATABASE_PASS, MYSQL_DATABASE_SCHEMA, \
                      use_unicode=True, charset='utf8')

        return con
    except Exception as e:
        print(e)
        return None

@app.before_first_request
def setup_logging():
    app.logger.addHandler(logging.StreamHandler())
    app.logger.setLevel(logging.INFO)

@app.route('/')
@app.route('/index')
def index():
    """Return index page"""
    global counter
    counter += 1
    app.logger.info("Received %s from: %s: %s", request.method, request.remote_addr, request.url)
    return "Service status: Running</h3>Requests<h4>Received %s from %s at URL %s</h4><p>Requests served: %s" % (request.method, request.remote_addr, request.url, counter)

@app.route('/events', methods=['GET','POST'])
@cross_origin() # allow all origins all methods.
def events():
    """Return disaster events from database"""
    is_empty = False

    con = connect_database()

    sql_query = "SELECT * FROM prithvidb.disastersFinal ORDER BY date"

    cursor = con.cursor()
    cursor.execute(sql_query)
    data = cursor.fetchall()
    if len(data) == 0:
        is_empty = True
    cursor.close()

    result = []

    if data is not None:
        app.logger.info("Success")
        for row in data:
            row_data = dict()
            # app.logger.info(row)
            row_data['date'] = row[1]
            row_data['title'] = row[2]
            row_data['description'] = row[3]
            row_data['country'] = row[4]
            row_data['city'] = row[5]
            row_data['latitude'] = row[6]
            row_data['longitude'] = row[7]
            row_data['name'] = row[8]
            result.append(row_data)
    else:
        error = "No user could be found"
    return json.dumps(result)

@app.route('/healthz')
def healthz():
    """Return health status"""
    return "Service is healthy"

@app.errorhandler(404)
def not_found_error(error):
    return "Error 404: Page Not Found", 404

@app.errorhandler(500)
def internal_error(error):
    return "Error 500: Administrator has been notified. Please try again in sometime", 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port, debug=os.getenv(DEBUG))
