FROM ruby:3.3-bookworm
ENV USER=unknown DEVICE=unknown LOCATION=unknown

RUN apt-get update && apt-get install -y iperf3
RUN curl -L https://github.com/ooni/probe-cli/releases/download/v3.21.1/miniooni-linux-amd64 > /usr/local/bin/miniooni && chmod +x /usr/local/bin/miniooni

WORKDIR /netsloth
COPY . .

RUN bundle config --global silence_root_warning 1
RUN bundle install

CMD ["/netsloth/bin/netsloth"]
