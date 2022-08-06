#!/bin/bash

echo "Make sure you've rebased over the current HEAD branch:"
echo "git rebase -i origin/main docs"

set -e  # exit on a non-zero return code from a command
set -x  # print a trace of commands as they execute

#rm -rf .build
#mkdir -p .build/symbol-graphs
#
#$(xcrun --find swift) build --target Lindenmayer --target LindenmayerViews \
#    -Xswiftc -emit-symbol-graph \
#    -Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs
#rm -f .build/symbol-graphs/SceneKitDebug* .build/symbol-graphs/Squirrel3*

# Enables deterministic output
# - useful when you're committing the results to host on github pages
export DOCC_JSON_PRETTYPRINT=YES

#xcrun docc convert Sources/Lindenmayer/Lindenmayer.docc \
#--enable-inherited-docs \
#--output-path Lindenmayer.doccarchive \
#--fallback-display-name Lindenmayer \
#--fallback-bundle-identifier com.github.heckj.Lindenmayer \
#--fallback-bundle-version 0.1.0 \
#--additional-symbol-graph-dir .build/symbol-graphs

#--transform-for-static-hosting \
#--hosting-base-path '/' \
#--emit-digest


# Swift package plugin for hosted content:
#
 $(xcrun --find swift) package \
     --allow-writing-to-directory ./docs \
     generate-documentation \
     --fallback-bundle-identifier com.github.heckj.Lindenmayer \
     --fallback-bundle-version 0.7.2 \
     --target Lindenmayer \
     --target LindenmayerViews \
     --output-path ./docs \
     --emit-digest \
     --disable-indexing \
     --transform-for-static-hosting \
     --hosting-base-path 'Lindenmayer'

# Generate a list of all the identifiers to assist in DocC curation
#

cat docs/linkable-entities.json | jq '.[].referenceURL' -r > all_identifiers.txt
sort all_identifiers.txt \
    | sed -e 's/doc:\/\/com\.github\.heckj\.Lindenmayer\/documentation\///g' \
    | sed -e 's/^/- ``/g' \
    | sed -e 's/$/``/g' > all_symbols.txt

echo "Page will be available at https://swiftviz.github.io/Lindenmayer/documentation/Lindenmayer/"
