FROM mhart/alpine-node:6.2.0
#FROM alpine:edge
RUN echo "ipv6" >> /etc/modules
RUN echo "http://dl-1.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
    echo "http://dl-3.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
    echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
    echo "http://dl-5.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories
#RUN apk add --no-cache --virtual .app-builddeps nodejs=6.7.0-r1
RUN apk add --no-cache --update nodejs=8.9.3-r0

WORKDIR /app
COPY ./package.json /app/package.json
RUN npm install --production

COPY ./.babelrc /app/.babelrc
COPY ./main.js /app/main.js
COPY ./src /app/src

CMD ["node", "main"]
