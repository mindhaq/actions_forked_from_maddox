#!/bin/sh

set -e

args=""
if [ $DEBUG = "true" ]
then
    args="$args -v"
fi

SSH_PATH="$HOME/.ssh"

mkdir -p "$SSH_PATH"
touch "$SSH_PATH/known_hosts"

echo "$PRIVATE_KEY" > "$SSH_PATH/deploy_key"

chmod 700 "$SSH_PATH"
chmod 600 "$SSH_PATH/known_hosts"
chmod 600 "$SSH_PATH/deploy_key"

eval $(ssh-agent)

echo Adding key
ssh-add $args "$SSH_PATH/deploy_key"

echo Scanning host
ssh-keyscan $args -t ssh-ed25519 $HOST >> "$SSH_PATH/known_hosts"

echo Connecting
ssh -o StrictHostKeyChecking=no -A -tt -p ${PORT:-22} $args $USER@$HOST "$*"
