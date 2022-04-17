# Specifies the container official image to run the codes
# Same as the action itself, Alpine is also a minial Docker image (More info: https://hub.docker.com/_/alpine)
FROM alpine:3.15.4

# Copies the container entrypoint Bash script file from the action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Determines the entrypoint Bash script file to execute when the docker container starts up
ENTRYPOINT ["sh", "/entrypoint.sh"]
