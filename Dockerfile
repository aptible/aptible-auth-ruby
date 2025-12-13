ARG RUBY_VERSION=2.3.1
FROM ruby:${RUBY_VERSION}

ENV BUNDLER_VERSION=1.17.3
RUN gem install bundler -v "${BUNDLER_VERSION}"

WORKDIR /app
COPY Gemfile /app
COPY aptible-auth.gemspec /app
RUN mkdir -p /app/lib/aptible/auth/
COPY lib/aptible/auth/version.rb /app/lib/aptible/auth/

RUN bundle install

COPY . /app

CMD ["bash"]
