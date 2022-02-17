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

export DOCC_JSON_PRETTYPRINT=YES

xcrun docc convert Sources/Lindenmayer/Lindenmayer.docc \
--enable-inherited-docs \
--output-path Lindenmayer.doccarchive \
--fallback-display-name Lindenmayer \
--fallback-bundle-identifier com.github.heckj.Lindenmayer \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs

#--transform-for-static-hosting \
#--hosting-base-path '/' \
#--emit-digest
