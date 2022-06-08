#!/usr/bin/env bash

set -e          # Stop the script on errors
set -u          # Unset variables are an error
set -o pipefail # Piping a failed process into a successful one is an error

# Check the script is run as by a user with docker's rights
if [ "$EUID" -ne 0 ]; then
  if ! id -nGz "$USER" | grep -qzxF docker; then
    echo "Please run with docker's rights (either run as root or add yourself to the docker group)"
    exit 1
  fi
fi

dangling_volumes="$(docker volume ls -q -f dangling=true | grep -E '^[a-z0-9]{64}$')"

echo "The following volumes will be removed:"
echo
echo $dangling_volumes | tr " " "\n"
echo
read -p "Proceed? [y/N]: " -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 0
fi

docker volume rm $dangling_volumes

echo "Done"
