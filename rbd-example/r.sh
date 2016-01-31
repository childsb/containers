#!/bin/sh

kubectl.sh delete rc rbd-tester
kubectl.sh delete pvc myclaim


kubectl.sh create -f secret.yaml

kubectl.sh create -f pv.yaml

# kubectl.sh create -f rbd.yaml
kubectl.sh create -f nginx.yaml
