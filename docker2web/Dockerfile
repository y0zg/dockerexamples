FROM alpine
MAINTAINER y0zg
RUN sed -i -e 's/dl-cdn.alpinelinux.org/147.75.32.21/' /etc/apk/repositories
RUN apk update && apk add ruby
RUN gem sources --add https://151.101.66.2/
RUN gem install sinatra --no-ri --no-rdoc
RUN gem install redis --no-ri --no-rdoc
ADD counter.rb counter.rb
EXPOSE 4567
ENTRYPOINT ["ruby","counter.rb"]
