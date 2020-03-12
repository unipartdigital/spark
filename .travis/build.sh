#!/usr/bin/env bash

set -e

usage() {
    cat <<EOF
    Usage: $0 IMAGE"
    Build Spark distribution package and build a Docker image IMAGE
EOF
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

image="$1"

echo "Running tests"
./dev/run-tests

echo "Building distribution package"
./dev/make-distribution.sh \
  --pip --tgz \
  # Build flags specified in the RELEASE file of https://downloads.apache.org/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz
  -Pmesos -Pyarn -Pkubernetes -Pflume -Psparkr -Pkafka-0-8 -Phadoop-2.7 -Phive -Phive-thriftserver

echo "Building Docker image $image"
docker build -t $image .
