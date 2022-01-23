To build and view the documentation locally:

```
mkdir -p .build/symbol-graphs

swift build --target Lindenmayer \
--target LindenmayerViews \
-Xswiftc -emit-symbol-graph \
-Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs

xcrun docc preview \
--fallback-display-name Lindenmayer \
--fallback-bundle-identifier Lindenmayer-swift \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs
```

Should show something like:

```
========================================
Starting Local Preview Server
	 Address: http://localhost:8000/documentation/squirrel3
	          http://localhost:8000/documentation/lindenmayer
	          http://localhost:8000/documentation/lindenmayerviews
	          http://localhost:8000/documentation/scenekitdebugtools
========================================
```


To generate the HTML:

```
mkdir -p html
xcrun docc convert \
--output-path html \
--fallback-display-name Lindenmayer \
--fallback-bundle-identifier Lindenmayer-swift \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs \
```

To get documentation coverage details:

```
xcrun docc convert \
--fallback-display-name Lindenmayer \
--fallback-bundle-identifier Lindenmayer-swift \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs \
--experimental-documentation-coverage \
--level brief
```


```
   --- Experimental coverage output enabled. ---
                | Abstract        | Curated         | Code Listing
Types           | 95% (112/118)   | 60% (71/118)    | 0.0% (0/118)
Members         | 3.6% (350/9750) | 95% (9218/9750) | 0.0% (0/9750)
Globals         | 41% (9/22)      | 91% (20/22)     | 0.0% (0/22)
```
