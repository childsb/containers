#!/bin/sh
docker build -t gluster:latest .
docker run --privileged=true -t gluster:latest
