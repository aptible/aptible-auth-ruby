ARG RUBY_VERSION=2.3.1
FROM ruby:${RUBY_VERSION}

ARG BUNDLER_VERSION=1.17.3
ENV BUNDLER_VERSION=${BUNDLER_VERSION}
RUN if [ "${BUNDLER_VERSION}" != "" ] ; then \
      gem install bundler -v "${BUNDLER_VERSION}" ; \
    fi

WORKDIR /app
COPY Gemfile /app/
COPY aptible-auth.gemspec /app/
RUN mkdir -p /app/lib/aptible/auth/
COPY lib/aptible/auth/version.rb /app/lib/aptible/auth/

RUN bundle install

COPY . /app

CMD ["bash"]
