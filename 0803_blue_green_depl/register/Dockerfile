FROM alpine:edge

RUN apk add --update nodejs=6.2.0-r0

WORKDIR /app
COPY ./package.json /app/package.json
RUN npm install --production

COPY ./.babelrc /app/.babelrc
COPY ./main.js /app/main.js
COPY ./src /app/src

CMD ["node", "main"]
