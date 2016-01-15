#!/bin/sh
export KUBE_GCE_INSTANCE_PREFIX="bc-e2e"
export KUBERNETES_PROVIDER=""
# go run hack/e2e.go -v -test -build -pushup --test_args="--ginkgo.focus=Volumes"
# go run hack/e2e.go -v -test -build -pushup --test_args="--ginkgo.focus=Volumes"
BIN_DIR=_output/local/go/bin
# cluster/kubectl.sh -s http://localhost:8080 delete namespace --all
$BIN_DIR//e2e.test --host="http://localhost:8080" --provider="local" --ginkgo.v=true --ginkgo.focus="Volume" --kubeconfig="$HOME/.kubernetes_auth" --e2e-output-dir=./
