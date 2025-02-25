FROM ruby:3.4-bookworm
ENV USER=unknown DEVICE=unknown LOCATION=unknown

RUN apt-get update && apt-get install -y iperf3
RUN curl -L https://github.com/ooni/probe-cli/releases/download/v3.24.0/miniooni-linux-amd64 > /usr/local/bin/miniooni && chmod +x /usr/local/bin/miniooni

WORKDIR /netsloth
COPY . .

RUN bundle install

CMD ["/netsloth/bin/netsloth"]
