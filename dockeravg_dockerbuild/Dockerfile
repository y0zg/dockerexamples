FROM alpine
MAINTAINER y0zg
RUN mkdir avg
RUN echo http://nl.alpinelinux.org/alpine/v3.6/main > /etc/apk/repositories; \
    echo http://nl.alpinelinux.org/alpine/v3.6/main >> /etc/apk/repositories
RUN apk update && apk add nodejs
ADD avg.js avg/

WORKDIR avg
ENTRYPOINT ["node","avg.js"]
