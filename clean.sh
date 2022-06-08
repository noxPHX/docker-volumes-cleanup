#!/usr/bin/env bash

set -e          # Stop the script on errors
set -u          # Unset variables are an error
set -o pipefail # Piping a failed process into a successful one is an error

# Check the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

initial_size="$(du -s /var/lib/docker/volumes | awk '{print $1}')"

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

reduced_size="$(du -s /var/lib/docker/volumes | awk '{print $1}')"

difference="$(($initial_size - $reduced_size))"

echo
echo "Total reclaimed space: ${difference}B ($((difference/1024))MB, $((difference/1024/1024))GB)"
