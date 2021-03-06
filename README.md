# syslog-ng-node 

syslog-ng logger and NodeJS on Alpine.  This image is a jumping off point to build 
a Node application around the syslog-ng logger.  

You *can* use it as is if you want
a quick means of capturing loggable sources.  But the agenda was a pre-configured
logging service on which to build a socket server for real-time data logging/monitoring.

Configuration is minimal but complete, out-of-the-box, as is.  You can pull
the image and add any extra syslog-ng plugins/libs you need...

<p>
  <img src="https://img.shields.io/docker/v/stevenktdev/syslog-ng-node">
  <img src="https://img.shields.io/docker/image-size/stevenktdev/syslog-ng-node">
  <img src="https://img.shields.io/github/repo-size/stkterry/syslog-ng-node">
  <a href="https://microbadger.com/images/stevenktdev/syslog-ng-node"><img src="https://images.microbadger.com/badges/commit/stevenktdev/syslog-ng-node.svg"></a>
  <a href="https://microbadger.com/images/stevenktdev/syslog-ng-node"><img src="https://images.microbadger.com/badges/image/stevenktdev/syslog-ng-node.svg"></a>
  <img src="https://img.shields.io/github/license/stkterry/syslog-ng-node">
</p>

<span>[<img src="https://img.shields.io/badge/DockerHub-Take%20Me!-brightgreen">](https://hub.docker.com/r/stevenktdev/syslog-ng-node) [<img src="https://img.shields.io/badge/GitHub-Let's%20Go!-brightgreen">](https://github.com/stkterry/syslog-ng-node/)</span>


**At A Glance (Important Bits)** </br>
<span style="font-size:.9em;">[Exposed Ports](#exposed-ports)</span> </br>
<span style="font-size:.9em;">[Exposed Volumes](#exposed-volumes)</span> </br>
<span style="font-size:.9em;">[Basic Use](#basic-use)</span> </br>
<span style="font-size:.9em;">[Defaults](#some-details)</span> </br>
<span style="font-size:.9em;">[Syslogger](#syslogger)</span> </br>
<span style="font-size:.9em;">[Overrides](#config-overrides)</span> </br>
<span style="font-size:.9em;">[Sanity Checks](#sanity-checks)</span> </br>
<span style="font-size:.9em;">[Example Use Case](#example-use-case)</span> </br>


##### Application Versions Used
| App          | Version                                                                                     | Maintainer                                    |
|--------------|---------------------------------------------------------------------------------------------|-----------------------------------------------|
| syslog-ng    | [3.30.1](https://github.com/syslog-ng/syslog-ng/releases/tag/syslog-ng-3.30.1)              | [syslog-ng/quest](https://www.syslog-ng.com/) |
| Node         | [15.2.1](https://github.com/nodejs/node/blob/master/doc/changelogs/CHANGELOG_V15.md#15.2.1) | [NodeJS](https://nodejs.org/en/)              |
| Alpine Image | [mhart/alpine-node:15.2.1](https://github.com/mhart/alpine-node)                            | [mhart](https://hub.docker.com/u/mhart)       |



### Configuration
Writes logs to `/var/log/syslog-ng/$PROGRAM.log`

A default config file is included at `/etc/syslog-ng.conf`.

##### Exposed Ports
| Port     | Type        | Note                                |
|----------|-------------|-------------------------------------|
| 514      | UDP         |                                     |
| 601      | TCP         | *now 601 by default!* :unamused:*   |
| ~~6514~~ | ~~TCP/TLS~~ | see*                                |
| unix     | socket      | `/var/run/syslog-ng/syslog-ng.lock` |

*&nbsp; previous versions used **602/tcp** because of a misidentified configuration issue
on my part within the ***syslog-ng.conf*** file.  This application now uses the default
**601/tcp** port!  The previous README.md erroneously stated that this applicaiton 
had port **6514/tcp** enabled for TLS by default.  This is not the case.  You're
welcome to expose the port and configure the conf file yourself if you need this
feature.  Check out the [syslog-ng docs](https://www.syslog-ng.com/technical-documents/doc/syslog-ng-open-source-edition/3.16/administration-guide/56)
for info on that.


##### Exposed Volumes
| Volume | Path                   |
|--------|------------------------|
| Logs   | `/var/log/syslog-ng`   |
| Socket | `/var/run/syslog-ng`   |
| Config | `/syslog-ng/config`    |

The *Config* volume is for adding your own config/startup files.  You will not find
defaults at this location. Look [here](#some-details) for that.

### Basic Use

##### Spin up a container that listens on *TCP* and saves logs to the *Logs* volume:
```sh
$ docker run -d `# start spinning up a container` \
  -p 602:602/tcp `# publish port 602 TCP to the network` \
  -v /var/log/my_logs:/var/log/syslog-ng `# map Logs volume to host at /var/my_logs` \
  --name my-log-monitor stevenktdev/syslog-ng-node `# set the container name and specify image, profit`
```
You'll find your logs output to `/var/log/my_logs` on your host machine

##### Setup a docker-compose file
```yaml
version: '3.7'
services:
  syslog-ng-node:
    container_name: syslog-ng-node
    image: stevenktdev/syslog-ng-node
    build: .
    ports:
      - "514:514/udp"
      - "602:602/tcp"
      - "6514:6514/tcp"
    volumes:
      - "./syslog-ng/logs:/var/log/syslog-ng"
      - "./syslog-ng/socket:/var/run/syslog-ng"
      - "./my-custom-config-folder:/syslog-ng/config"
```
##### Config Overrides
You can replace the default config and startup files by mounting a config folder
to `/syslog-ng/config` on the container, with your overrides, as shown in the example above.
The files are ***syslog-ng.conf*** and ***startup.sh***, respectively.


##### Syslogger
Included is a simple wrapper script for syslog-ng, which can be called via `syslogger`.
It makes this implementation a little bit more functional by adding *start*, *stop*, 
*restart*, *getPID*, etc. You can also pass any syslog-ng options through it.
```sh
# Basic Use
# syslogger {primary-command} {syslog-ng options ...}
# Examples
$ syslogger start -F -f /custom.conf # equivalent to 'syslog-ng -F -f /custom.conf'
$ syslogger stop # stops syslog-ng and prints the PIDs
$ syslogger getPID # PIDs of the current syslog-ng processes, useful for debugging
$ syslogger help # list of commands available to syslogger
```

##### Some details
- you can find the default ***startup.sh*** file in `/app/`
- ***syslog-ng.conf*** can be found in `/etc/`
- an entrypoint is used to map the auto config overrides, setting your own entrypoint
will prevent this behavior
- inspired in part by [syslog-ng-alpine](https://github.com/mumblepins-docker/syslog-ng-alpine)
- log files and sockets are protected from tampering as is standard (you can override
this with a custom *syslog-ng.conf*) but are viewable by default.
- UDP is typically quite slow and only reliable over local networks, TCP is what's up


### Sanity Checks
You can test access to your logger as follows using [netcat](http://netcat.sourceforge.net/):

```sh
# Assuming you've mounted the container and published ports 602/tcp and 514/udp,
# and set your log mount point to /var/log/my_logs.

# Here the user is sending a message to port 602 over TCP
echo netcat: "pinapple is allowed on pizza" | nc -t -w0 localhost 602

# And here we're sending a message to port 514 over UDP
echo netcat: "remember to breath" | nc -u -w0 localhost 514
```
You should expect to find a new file named *netcat.log* at `/var/log/mylogs/netcat.log`
on your host machine.  Remember that these files are write protected by default but
you can read their contents, where you should expect to find something like the following:
```log
2020-11-25T21:49:22+00:00 172.24.0.1 netcat: pinapple is allowed on pizza
2020-11-25T21:49:40+00:00 172.24.0.1 netcat: remember to breath
```

### Example Use Case
Here's an example where a user might have one or many Docker containers they'd
like to implement logging for.  The use case is as follows:

1) You've got one (or more) containers you're going to log
2) You intend to keep your logger container on the same host
3) Your destination then is *localhost/127.0.0.1*
4) You're going to stick with the defaults and use 601/TCP

#### 1) Setting Up the Logger
Just refer to the [Basic Use](#basic-use) section of the document to spin up your
***syslog-ng-node*** container!

#### Setting Up What You'd Like To Log
Let's say you've got an image, *my-cool-image*, here's how you set your log driver
and log destination/port

Mostly from the [Docker Docs](https://docs.docker.com/config/containers/logging/syslog/):
```sh
$ docker run -d `# start spinning up a container` \
  --log-driver syslog --log-opt syslog-address=tcp://127.0.0.1:601 `# set driver to syslog and address to localhost:601/tcp` \
  --log-opt tag=my-cool-log `# set a log option to name your log file, refer to Docker docs for more info on this!` \
  --name my-cool-name my-cool-image `# set the container name and specify image, profit`
```
And that's it!  Logs will be dumped to a log file 'my-cool-log.log' in whatever 
default directory you'd defined when setting up the syslog-ng-node container. You 
can setup as many containers as you want that way.  Again, refer to the Docker docs 
for a mess of better configuration options.  

Of course a better option might be to configure the app you want to log via a 
*docker-compose.yml* file:
```yaml
version: '3.7'
services:
  my-cool-service:
    container_name: my-cool-name
    image: my-cool-image
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://127.0.0.1:601"
        tag: "my-cool-log"
```

You're not limited to logging only Docker containers, needless to say, they're
just the easiest to demonstrate.