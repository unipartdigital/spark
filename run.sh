#!/usr/bin/env bash

set -e

# Load Spark env vars
. spark-config.sh
. load-spark-env.sh

export SPARK_NO_DAEMONIZE=1

if [ "$SPARK_MODE" == "master" ]; then
    log=spark-master.out
    cmd=start-master.sh
    args=()
    echo "==> Starting Spark in master mode"
else
    log=spark-worker.out
    cmd=start-slave.sh
    args=("$SPARK_MASTER_URL")
    echo "==> Starting Spark in worker mode"
fi

mkdir -p $SPARK_LOG_DIR
ln -sf /dev/stdout $SPARK_LOG_DIR/$log

exec "$cmd" "${args[@]}" >> $SPARK_LOG_DIR/$log
