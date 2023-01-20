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

After creating your user, the next thing you must do is create a bucket. Navigate to Load Data > Buckets > Create Bucket.

Next create an API token from Load Data > API Tokens > Generate API Token.

Configuration
----------------------------

Edit the file `config/config.yml` with the bucket and API token you created in the setup.

Run
----------------------------

Run netsloth:

    bin/netsloth

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
