FROM docker.io/library/ruby:3.4-trixie
ENV USER=unknown DEVICE=unknown LOCATION=unknown

RUN apt-get update && apt-get install -y curl iperf3
RUN curl -L https://github.com/ooni/probe-cli/releases/download/v3.27.0/miniooni-linux-amd64 > /usr/local/bin/miniooni && chmod +x /usr/local/bin/miniooni

WORKDIR /netsloth
COPY . .

RUN bundle install

CMD ["/netsloth/bin/netsloth"]
