# FoundationDB

## Purpose

This how-to is supposed to be for learning. It was writen for developers who wants to try the FoundationDB.

> [FoundationDB](https://apple.github.io/foundationdb/index.html) is a distributed database designed to handle large volumes of structured data across clusters of commodity servers.

<sub>You can find the source code for this article [here]().</sub>

## Requirements

I assume you have got hand-on experience with `Docker`, also you’re comfortable with bash shell.
I'll use some piece of `golang` but you might use another [api language bindings](https://apple.github.io/foundationdb/downloads.html#api-language-bindings). 

<sub>
You may ask why I use Docker, I found Docker containers are very handy in order to try something new and share the expirience.
Also it keeps my host machine clean from the stuff I dont need.
</sub>

## Checklist

- [x] [Prepare](#prepare)
- [x] [Build server](#build-server)
- [x] [Build client](#build-client)
- [x] [Some code](#some-code)
- [x] [Closing](#closing)
- [x] [Disclaimer](#disclaimer)
- [x] [Donation](#donation)

## Prepare

We'll use `Ubuntu 16.04` docker images with a [plain `.deb` installation](https://apple.github.io/foundationdb/local-dev.html#download-the-foundationdb-package).
Also we'll use some golang code in order to explore the `FoundationDB` features.
Let's start from cloning the [sources]().

In order to allow containers talk to each other we will use `Docker` network feature.
Create a network:

```bash
$> docker network create fdbnetwork
```

## Build server

Here is the `Dockerfile` for server image:

```Dockerfile
FROM ubuntu:16.04

RUN apt-get update && apt-get install --fix-missing --yes wget vim python 

RUN wget https://www.foundationdb.org/downloads/6.0.15/ubuntu/installers/foundationdb-clients_6.0.15-1_amd64.deb
RUN dpkg -i foundationdb-clients_6.0.15-1_amd64.deb
RUN wget https://www.foundationdb.org/downloads/6.0.15/ubuntu/installers/foundationdb-server_6.0.15-1_amd64.deb

COPY start.sh .
```

There is a shell script `start.sh`, that script contains a bunch of commands to edit configuration for `FoundationDB`.

Now lets build `FoundationDB` server image:

```bash
$> docker build -t fdb . -f FDB.Dockerfile
# ... output omited
```

Next step is start the `FoundationDB` server container and add public ip address of container to `FoundationDB` configuration:

```bash
# log into container 
$> docker run -it --rm -v $(pwd)/conf:/etc/foundationdb -p 4500:4500 --network fdbnetwork fdb bash
# show public ip address of container
$> getent hosts
127.0.0.1       localhost
127.0.0.1       localhost ip6-localhost ip6-loopback
172.17.0.2      fd4051d44517
# in my case it's 172.17.0.2
# open start.sh with vim editor
# and set ip address
$> vim start.sh
# ...
# set FDB_PUBLIC_ADDR variable to ip address we've above
# run start.sh script
$> ./start.sh
# you may see
# ...
>>> configure new single memory
Database created
>>> status
Using cluster file /etc/foundationdb/fdb.cluster.
# ...
# output omited
fdb>
```

OK, the `FoundationDB` server container is up and running, the public ip for client containers is exposed. 

## Build client

Now it is time to run `FoundationDB` client container. As you see early we've run server container with option `-v $(pwd)/conf:/etc/foundationdb`,
this option creates a docker volume so client container is able to copy `foundationdb.conf` file at the build step.

Here is the `Dockerfile` for client image:

```Dockerfile
FROM ubuntu:16.04

RUN apt-get update && apt-get install --fix-missing --yes wget golang python git mono-complete make default-jre m4

RUN wget https://www.foundationdb.org/downloads/6.0.15/ubuntu/installers/foundationdb-clients_6.0.15-1_amd64.deb
RUN dpkg -i foundationdb-clients_6.0.15-1_amd64.deb

ENV GOPATH /usr/bin

# Download golang foundationdb api bindings
RUN wget https://raw.githubusercontent.com/apple/foundationdb/master/bindings/go/fdb-go-install.sh

# Download golang foundationdb api bindings
RUN chmod +x /fdb-go-install.sh && /fdb-go-install.sh install --fdbver 6.0.15

# Copy the example app
RUN mkdir -p app
COPY app/ app

# Copy server configuration
COPY conf/foundationdb.conf /etc/foundationdb/
```

Now lets build `FoundationDB` client image:

```bash
$> docker build -t fdbc . -f FDBClient.Dockerfile
# ... output omited
```

Run client container, after log into client we need create a `FoundationDB` cluster file pointed to our server container.
Check the file `fdb.cluster` under `conf` directory on the host machine, `cat conf/fdb.cluster`, in my case the content is `g2Yn1L0t:whopt7JR@127.0.0.1:4500`.

```bash
$> docker run -it --rm --network fdbnetwork fdbc bash
# change 127.0.0.1 from the cluster file to server public ip
$> echo "g2Yn1L0t:whopt7JR@172.17.0.2:4500" > /etc/foundationdb/fdb.cluster
# lets check the connection from client to server
$> fdbcli
Using cluster file /etc/foundationdb/fdb.cluster.

The database is available.

Welcome to the fdbcli. For help, type `help'.
fdb> status details

Using cluster file /etc/foundationdb/fdb.cluster.

Configuration:
...
... output omited
...
fdb>
```

Lets check if both containers has connection.

Client container:

```bash
# need to enable writemode
fdb> writemode on
fdb> set foo bar
Committed (496648977)
```

Server container:

```bash
fdb> get foo
`foo' is `bar'
```

Good, at this point we have two `FoundationDB` containers with server and client, both containers connected and runned.
It's time to run some code. 

## Some code

In the client containers we have a simple example with measuring of `1_000_000` sets & gets.
To run that code use next commands:

```bash
fdb> exit
$> cd /app
$> go run main.go
...
```

You can observe the server process perfomance details (on the server container):

```bash
$> fdbcli
fdb> status details
... output omited
```

## Closing

In this how-to we've created two containers with `FoundationDB` one acts as server and second one as client.
The client container contains a simple example of code with set & get commands. 

Now you have clean room to play with `FoundationDB`. 

Try other [api language bindings](https://apple.github.io/foundationdb/downloads.html#api-language-bindings).
Learn about [data modeling](https://apple.github.io/foundationdb/data-modeling.html).
 
## Donation

Are you like this tutorial? Buy me a beer and I'll write more tutorials like this one:

* BTC - 1QHQU9WySErTBBU3tFKQB1GrBWNZ5YVrV1
* ETH - 0xD7cc10f0d70Fd8f9fB83D4eF9250Fc9201981e3a

Thank you!

## Disclaimer

> :exclamation: you are using this guide at your own risk.. 

<sub>P.S. forgive me my bad English, it’s not my native language.</sub>
<sub>Happy hacking!</sub>
