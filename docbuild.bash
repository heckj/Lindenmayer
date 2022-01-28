#!/bin/bash

set -e
set -x

rm -rf html
mkdir -p html

rm -rf .build
mkdir -p .build/symbol-graphs

# Lindenmayer.symbols.json              LindenmayerViews.symbols.json         SceneKitDebugTools@simd.symbols.json
# Lindenmayer@Swift.symbols.json        SceneKitDebugTools.symbols.json       Squirrel3.symbols.json
# Lindenmayer@simd.symbols.json         SceneKitDebugTools@Swift.symbols.json

swift build --target Lindenmayer \
--target LindenmayerViews \
-Xswiftc -emit-symbol-graph \
-Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs

# cull the non-Lindenmayer specific builds from the symbol graph files
rm -f .build/symbol-graphs/SceneKitDebug* .build/symbol-graphs/Squirrel3*

xcrun docc convert Sources/Lindenmayer/Lindenmayer.docc \
--analyze \
--fallback-display-name Lindenmayer \
--fallback-bundle-identifier com.github.heckj.Lindenmayer \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs \
--experimental-documentation-coverage \
--level brief

xcrun docc convert Sources/Lindenmayer/Lindenmayer.docc \
--enable-inherited-docs \
--output-path html \
--fallback-display-name Lindenmayer \
--fallback-bundle-identifier com.github.heckj.Lindenmayer \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs \
--emit-digest

# Generate a list of all the identifiers for DocC curation
# find html/data -name "*.json" -exec jq '.identifier.url' {} \; | sed -e 's/"//g'> html/all_identifiers.txt
# sort html/all_identifiers.txt | sed -e 's/^/ - ``/g' | sed -e 's/$/``/g' > docc_identifiers.txt
