FROM ubuntu
RUN apt-get update
RUN apt-get install -y
CMD curl | sh
