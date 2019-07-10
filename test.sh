#!/usr/bin/env bash

set -o pipefail
set -o errexit

./tests/test-core.joke
./tests/functional.sh
