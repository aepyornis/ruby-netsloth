
FROM buildpack-deps:bullseye

ENV USER=unknown DEVICE=unknown LOCATION=unknown

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ruby bundler iperf3 && \
    rm -rf /usr/share/doc/* && \
    rm -rf /usr/share/locale/* && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/ooni/probe-cli/releases/download/v3.17.1/miniooni-linux-amd64 > /usr/local/bin/miniooni-linux-amd64 && chmod +x /usr/local/bin/miniooni-linux-amd64

WORKDIR /netsloth
COPY . .

RUN bundle config --global silence_root_warning 1
RUN bundle

CMD ["bin/netsloth"]