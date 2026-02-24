# settings for Rails development environment

FROM ruby:3.3.10

WORKDIR /aws_pet_tracking_app

# psql dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev

# Ruby tooling
RUN gem install bundler rails
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .

EXPOSE 3100

CMD ["bin/rails", "s", "-b", "0.0.0.0", "-p", "3100"]