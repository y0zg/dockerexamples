FROM mhart/alpine-node:5.6.0

WORKDIR /app

# add package.json and run npm install before adding the rest of the files
# this way, you only run npm install when package.json changes
ADD package.json /app
RUN sed -i -e 's/dl-cdn.alpinelinux.org/147.75.32.21/' /etc/apk/repositories
RUN npm install

# add the rest of the files
ADD . /app

ENV NODE_ENV production
CMD ["./node_modules/.bin/knex", "migrate:latest"]
