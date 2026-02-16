# settings for Rails development environment

FROM ruby:3.3.10

WORKDIR /aws_pet_tracking_app

# System/build deps (for native gems + JS tooling)
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     nodejs \
#     npm \
#   && rm -rf /var/lib/apt/lists/* \
#   && npm install -g yarn

# Ruby tooling
RUN gem install bundler rails
# COPY Gemfile Gemfile.lock ./
# RUN bundle install
# COPY . .

EXPOSE 3100

# CMD ["bin/rails", "s", "-b", "0.0.0.0", "-p", "3100"]