FROM alpine
MAINTAINER y0zg
RUN mkdir avg
RUN apk update && apk add nodejs
ADD avg.js avg/
WORKDIR avg
ENTRYPOINT ["node","avg.js"]
