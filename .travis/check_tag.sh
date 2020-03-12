#!/usr/bin/env bash

# If this is a tag release, ensure that the Spark version and tag name match.

set -e

if [ -z "$TRAVIS_TAG" ] && [ "$TRAVIS_TAG" != "$SPARK_PACKAGE_VERSION" ]
  then
    echo "Tag name does not match Spark version"
    exit 1;
fi
