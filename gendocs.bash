#!/bin/bash

set -e
set -x

mkdir -p docs
export DOCC_JSON_PRETTYPRINT=YES

# Swift package plugin for hosted content:
#
xcrun swift package \
    --allow-writing-to-directory ./docs \
    --target MeshGenerator \
    generate-documentation \
    --output-path ./docs \
    --emit-digest \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path 'Lindenmayer'

