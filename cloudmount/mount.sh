#!/bin/sh

# export S3User=longgeneratedid
# export S3Secret=longnastygernatedsecret

if [[ $# -lt 2 ]]
then
  echo
  echo "set S3User and S3Secret env then.."
  echo 
  echo "Usage: $0 bucket mountpoint"
  echo 
  echo "Example: $0 snuffy /mnt/snuffy"
  echo
  exit
fi

docker run --privileged -e S3User=$S3User -e S3Secret=$S3Secret -v $2:/mnt/mountpoint:shared --cap-add SYS_ADMIN cloudmount $1 /mnt/mountpoint -o passwd_file=/etc/passwd-s3fs -d -d -f -o f2 -o curldbg
