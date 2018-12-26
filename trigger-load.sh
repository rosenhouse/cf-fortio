#!/bin/bash

set -euo pipefail

apps_domain="$(cat manifest-vars.yml | grep apps_domain | cut -d ':' -f2 | sed 's/ //g')"
internal_domain="apps.internal"

runOnce() {
  name=$1
  host=$2
  concurrency=$3

  label="$name-$concurrency"
  curl "http://fortio.$apps_domain/fortio/?labels=$label&url=http://$host/echo&qps=1000&t=3s&n=&c=$concurrency&p=50%2C+75%2C+90%2C+99%2C+99.9&r=0.0001&H=User-Agent%3A+fortio.org%2Ffortio-1.3.1-pre&H=&H=&H=&runner=http&grpc-ping-delay=0&save=on&load=Start"
}

runOnce localhost localhost:8080 8
runOnce localhost localhost:8080 16

runOnce c2c fortio-echo-server.$internal_domain:8080 8
runOnce c2c fortio-echo-server.$internal_domain:8080 16

runOnce envoy fortio-echo-server.istio.$apps_domain 8
runOnce envoy fortio-echo-server.istio.$apps_domain 16

runOnce gorouter fortio-echo-server.$apps_domain 8
runOnce gorouter fortio-echo-server.$apps_domain 16
