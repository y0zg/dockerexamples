FROM debian:stretch
RUN touch /1this-is-${HOSTNAME}
RUN touch /2this-is-$(hostname)
RUN ["touch","3this-is-${HOSTNAME}"]
