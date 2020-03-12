#!/usr/bin/env bash
# Set up environment variables used in .travis.yml config
set -e

export SPARK_PACKAGE_VERSION=$(mvn help:evaluate -Dexpression=project.version $@ 2>/dev/null\
      | grep -v "INFO"\
      | grep -v "WARNING"\
      | tail -n 1)
export SPARK_IMAGE_NAME="$TRAVIS_REPO_SLUG":"$PACKAGE_VERSION"
