#!/bin/sh

export S3User=s3id
export S3Secret=s3secret
# docker run --privileged -e S3User=$S3User -e S3Secret=$S3Secret -i -t cloudmount bash

docker run --privileged -e S3User=$S3User -e S3Secret=$S3Secret -v `pwd`/s3:/mnt/mountpoint cloudmount snuffy /mnt/mountpoint -o passwd_file=/etc/passwd-s3fs -d -d -f -o f2 -o curldbg
# docker run --privileged -v `pwd`/s3:/mnt/mountpoint cloudmount snuffy /mnt/mountpoint -o passwd_file=/etc/passwd-s3fs
