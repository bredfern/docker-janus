# Janus Gateway

-   This image contains the meetecho janus webrtc gateway  ([https://github.com/meetecho/janus-gateway](https://github.com/meetecho/janus-gateway))

-   It uses the google stun server in the default run command  which is not what you would likely want for production or your own qa tiers tere are a few issues to be aware of, [take a look at the presentation](https://www.januscon.it/2019/talk.php?t=docker) for different issues using Janus with docker in a production environment.

# Build
From within the project folder run this command:

    docker build --tag=janus .


## Ports

| Port   | Description       |
|--------|-------------------|
| 8088   | RESTful API       |
| 8188   | WebSocket API     |
| 8089   | Restful on SSL    |
| 8189   | Websocket on SSL  |
| 7088   | RESTful Admin API |
| 7188   | Admin API on SSL  |

## Run
From within the project folder run this command:

docker run -d -p 7088:7088 -p 7089:7089 -p 8088:8088 -p 8089:8089 -p 8188:8188 -p 8189:8189 janus
