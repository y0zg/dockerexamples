FROM mhart/alpine-node:5.6.0

EXPOSE 3000

WORKDIR /app
ADD ./package.json /app/package.json
RUN npm install

ADD . /app

CMD ["node", "server.js"]
