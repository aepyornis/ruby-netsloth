
FROM buildpack-deps:bullseye

ENV USER=unknown DEVICE=unknown LOCATION=unknown

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      apt-file ruby bundler npm iperf3 && \
    apt-file update && \
    rm -rf /usr/share/doc/* && \
    rm -rf /usr/share/locale/*

WORKDIR /netsloth
RUN npm install --production fast-cli

# fast-cli requires puppeteer to run, which builds its own chromium and requires
# a bunch of libraries:
RUN ldd node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome | grep "not found" | awk '{print $1}' | apt-file --from-file search - | cut -f1 -d: | uniq | grep -v 'firefox\|dbus-tests\|thunderbird' | xargs apt-get install -y --no-install-recommends

RUN curl -L https://github.com/ooni/probe-cli/releases/download/v3.17.1/miniooni-linux-amd64 > /usr/local/bin/miniooni-linux-amd64 && chmod +x /usr/local/bin/miniooni-linux-amd64

COPY . .

RUN bundle config --global silence_root_warning 1
RUN bundle

CMD ["bin/netsloth"]