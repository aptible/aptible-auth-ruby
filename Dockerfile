ARG RUBY_VERSION=3.4
FROM ruby:${RUBY_VERSION}

RUN apt-get upgrade -y ca-certificates

WORKDIR /app
COPY Gemfile /app/
COPY aptible-auth.gemspec /app/
RUN mkdir -p /app/lib/aptible/auth/
COPY lib/aptible/auth/version.rb /app/lib/aptible/auth/

RUN bundle install

COPY . /app

CMD ["bash"]
