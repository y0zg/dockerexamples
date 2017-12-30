FROM alpine:latest
RUN apk add --update curl
RUN curl -SL https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33.tar.gz \
--output tomcat.tar.gz
RUN tar -xvzf tomcat.tar.gz -C /tmp/
