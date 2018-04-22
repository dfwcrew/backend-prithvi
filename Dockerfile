FROM python:2.7-slim

RUN apt-get -y update && apt-get install -qq -y \
  build-essential --no-install-recommends && \
  apt-get install -y --no-install-recommends apt-utils && \
  apt-get install -y python-dev libmysqlclient-dev

# Grab requirements.txt.
ADD requirements.txt /tmp/requirements.txt

# Install dependencies
RUN pip install -qr /tmp/requirements.txt

# Add our code
ADD . /opt/webapp/
WORKDIR /opt/webapp

EXPOSE 8000

CMD gunicorn -b 0.0.0.0:8000 server:app --worker-class gevent
