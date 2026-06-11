LINKER_FLAGS := $(shell pkg-config --libs gtk4)
C_FLAGS := $(shell pkg-config --cflags gtk4)
SWIFT_LINKER_FLAGS ?= -Xlinker $(shell echo $(LINKER_FLAGS) | sed -e "s/ / -Xlinker /g" | sed -e "s/-Xlinker -Wl,-framework,/-Xlinker -framework -Xlinker /g")
SWIFT_C_FLAGS ?= -Xcc $(shell echo $(C_FLAGS) | sed -e "s/ / -Xcc /g")

# WebAssembly build configuration.
# The wasm C deps (_CJavaScriptKit) need a clang with the WebAssembly target,
# which Apple's Xcode toolchain lacks. Drive the build through the open-source
# swift.org toolchain (TOOLCHAINS=swift selects swift-latest). Override the SDK
# with `make wasm WASM_SDK=<name>` (see `swift sdk list`).
WASM_TOOLCHAIN ?= swift
WASM_SDK ?= swift-6.3.2-RELEASE_wasm
WASM_PRODUCT ?= TokamakDemo

all: build

build:
	swift build --enable-test-discovery --product TokamakGTKDemo $(SWIFT_C_FLAGS) $(SWIFT_LINKER_FLAGS)

run: build
	.build/debug/TokamakGTKDemo

wasm:
	TOOLCHAINS=$(WASM_TOOLCHAIN) swift build --product $(WASM_PRODUCT) --swift-sdk $(WASM_SDK)

.PHONY: all build run wasm
