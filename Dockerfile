FROM ruby:2.4.1
WORKDIR /myapp
COPY . .
RUN bundle install

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]