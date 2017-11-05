FROM ubuntu
MAINTAINER y0zg
RUN echo "nameserver 192.168.1.1" >> /etc/resolv.conf
RUN apt-get update
RUN apt-get install iputils-ping
CMD ["ping","192.168.1.1"]
