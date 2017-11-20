FROM mhart/alpine-node:5.6.0

EXPOSE 3000

WORKDIR /app
ADD . /app
RUN sed -i -e 's/dl-cdn.alpinelinux.org/147.75.32.21/' /etc/apk/repositories
RUN npm install

CMD ["node","server.js"]

