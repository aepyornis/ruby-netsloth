
FROM buildpack-deps:bullseye

WORKDIR /netsloth
ADD . /netsloth/

RUN apt-get update
RUN apt-get install -y --no-install-recommends ruby bundler npm iperf3
RUN bundle

RUN npm install fast-cli

# fast-cli requires puppeteer to run, which builds its own chromium and requires
# a bunch of libraries:
RUN apt-get install -y apt-file && apt-file update
RUN ldd node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome | grep "not found" | awk '{print $1}' | apt-file --from-file search - | cut -f1 -d: | uniq | grep -v 'firefox\|dbus-tests\|thunderbird' | xargs apt-get install -y --no-install-recommends

CMD ["bin/netsloth"]
#CMD ["/bin/bash"]