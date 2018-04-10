FROM ubuntu:16.04

# Install Ruby and Rails dependencies
RUN apt-get update && apt-get install -y \
  libcurl4-openssl-dev \
  docker.io \
  ruby \
  ruby-dev \
  build-essential \
  libxml2-dev \
  libxslt1-dev \
  zlib1g-dev  #required for gem install

COPY . /hyperflow-amqp-executor
WORKDIR /hyperflow-amqp-executor

RUN gem build hyperflow-amqp-executor.gemspec && \
    gem install hyperflow-amqp-executor

CMD hyperflow-amqp-executor