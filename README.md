Netsloth
============================

This is a simple script that calls various benchmarking and network troubleshooting
tools and uploads this data to InfluxDB.

Set up InfluxDB
----------------------------

For testing, the easy thing to do is run the InfluxDB container on a server:

    docker run --rm --name influxdb -p 8086:8086 -v influx_volume:/var/lib/influxdb2 influxdb:latest

Open http://myserver:8086 to set up initial user. Alternately, see https://hub.docker.com/_/influxdb/ for many ways to initialize the container with an already created user.

When it asks you to set up InfluxDB just ignore that step.

After creating your user, the next thing you must do is create a bucket. Navigate to Load Data > Buckets > Create Bucket. Change 'config.yml' entry 'bucket' to match the name you gave the bucket.

Next create an API token from Load Data > API Tokens > Generate API Token.

Configuration
----------------------------

Edit the file `config/config.yml` with the bucket and API token you created in the setup.

Helper programs
----------------------------

iperf3:

    sudo apt install iperf3

miniooni:

    download from https://github.com/ooni/probe-cli/releases

fast-cli:

    cd netsloth
    sudo apt install npm
    npm install fast-cli

Run
----------------------------

Run netsloth:

    bin/netsloth

Docker
----------------------------

Build image:

    docker build -t netsloth .

Run image

    docker run -it netsloth

Further Reading
----------------------------

InfluxDB client gem: https://github.com/influxdata/influxdb-client-ruby

Querying data in Flux: https://docs.influxdata.com/influxdb/cloud/query-data/flux/

Classes on learning InfluxDB: https://university.influxdata.com/

Example Graphs
----------------------------

A simple graph showing the aggregate bandwidth for all users at a specific location, grouped in 5 minute windows:

    from(bucket: "network")
      |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
      |> filter(fn: (r) => r["_measurement"] == "iperf3")
      |> filter(fn: (r) => r["_field"] == "receiver_bits_per_second")
      |> filter(fn: (r) => r["location"] == "seattle")
      |> drop(columns: ["user"])
      |> aggregateWindow(every: 5m, fn: median, createEmpty: false)
      |> yield(name: "median")

If you want to further aggregate over all devices:

      |> drop(columns: ["user", "device"])


Using calyxos and termux
--------------------------------------------

Install [termux from f-droid](https://f-droid.org/en/packages/com.termux/)

Open termux and install packages: `pkg update && pkg install curl git ruby iperf3`

Clone netsloth and install packages

```
git clone https://0xacab.org/calyx/experiments/netsloth.git
cd netsloth
bundle install
```

Download miniooni: `curl -L -O "https://github.com/ooni/probe-cli/releases/download/v3.16.7/miniooni-android-arm64" && chmod +x miniooni-android-arm64`

Change variables in __config/config.yml__ to match your location, device, etc.

By default `iperf3_cmd` is located at  `/data/data/com.termux/files/user/bin/iperf3`
