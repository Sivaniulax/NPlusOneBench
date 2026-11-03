FROM ruby:3.3-slim-bookworm

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential libpq-dev postgresql-client \
      python3 python3-venv curl unzip git \
 && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/opt/venv PATH=/opt/venv/bin:$PATH
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m venv /opt/venv && pip install -q -r /tmp/requirements.txt

COPY harness/Gemfile /opt/harness/Gemfile
ENV BUNDLE_GEMFILE=/opt/harness/Gemfile
RUN bundle install --quiet

WORKDIR /app
