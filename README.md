## syslog-ng-node 

syslog-ng logger and NodeJS on Alpine.  This image is merely a jumping off point to build a Node/Express application around the syslog-ng logger.

<p>
  <img src="https://img.shields.io/docker/v/stevenktdev/syslog-ng-node">
  <img src="https://img.shields.io/docker/image-size/stevenktdev/syslog-ng-node">
  <img src="https://img.shields.io/github/repo-size/stkterry/syslog-ng-node">
  
</p>

<span>[<img src="https://img.shields.io/badge/DockerHub-Take%20Me!-brightgreen">](https://hub.docker.com/repository/docker/stevenktdev/syslog-ng-node/general) [<img src="https://img.shields.io/badge/GitHub-Let's%20Go!-brightgreen">](https://github.com/stkterry/syslog-ng-node/)</span>


**At A Glance (Important Bits)** </br>
<span style="font-size:.9em;">[Exposed Ports](#exposed-ports)</span> </br>
<span style="font-size:.9em;">[Exposed Volumes](#exposed-volumes)</span> </br>
<span style="font-size:.9em;">[Basic Use](#basic-use)</span> </br>
<span style="font-size:.9em;">[Defaults](#some-details)</span> </br>
<span style="font-size:.9em;">[Overrides](#config-overrides)</span> </br>
<span style="font-size:.9em;">[Sanity Checks](#sanity-checks)</span> </br>


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
| Port | Type    | Note                                |
|------|---------|-------------------------------------|
| 514  | UDP     |                                     |
| 602  | TCP     | *not 601!* :unamused: *see**        |
| 6514 | TCP/TLS |                                     |
| unix | socket  | `/var/run/syslog-ng/syslog-ng.lock` |

*&nbsp;port 601 maybe be blocked for some users who wish to run syslog-ng on their host or some other service, 602 is used on this app for that reason


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
docker run -d `# start spinning up a container` \
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
