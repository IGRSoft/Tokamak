# syntax=docker/dockerfile:1
# Stage 1 — build the SwiftWasm bundle.
# The official swift:6.3.2 (Linux) image ships an open-source clang WITH the
# WebAssembly backend (unlike Apple's Xcode clang), so wasm C targets compile.
FROM swift:6.3.2 AS build
WORKDIR /src

# Install the Swift SDK for WebAssembly (wasm32-unknown-wasip1).
RUN swift sdk install \
      https://download.swift.org/swift-6.3.2-release/wasm-sdk/swift-6.3.2-RELEASE/swift-6.3.2-RELEASE_wasm.artifactbundle.tar.gz \
      --checksum a61f0584c93283589f8b2f42db05c1f9a182b506c2957271402992655591dd7c

# Optional: binaryen for wasm-opt (shrinks the release wasm).
RUN apt-get update && apt-get install -y --no-install-recommends binaryen && rm -rf /var/lib/apt/lists/*

COPY . .

# Bundle TokamakDemo to a browser ESM module + optimized .wasm via PackageToJS.
RUN swift package --swift-sdk swift-6.3.2-RELEASE_wasm --disable-sandbox \
      js --product TokamakDemo -c release --use-cdn \
 && cp docker/index.html .build/plugins/PackageToJS/outputs/Package/index.html

# Stage 2 — serve the static bundle.
FROM nginx:alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/.build/plugins/PackageToJS/outputs/Package /usr/share/nginx/html
EXPOSE 80
