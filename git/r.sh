#!/bin/sh
docker build -t fedora:latest .
docker run -i -v /root/shared:/root/shared -t fedora:latest bash
