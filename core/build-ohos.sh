#!/bin/bash
# cross-compile Argyll for HarmonyOS (ARM64)
set -e

# установи в систему: cmake, ohos-sdk (native/hi3861)
SDK_ROOT="$HOME/ohos-sdk/linux"
TOOLCHAIN="$SDK_ROOT/native/build/cmake/ohos.toolchain.cmake"

mkdir -p build-ohos && cd build-ohos
cmake .. -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
         -DCMAKE_BUILD_TYPE=Release \
         -DENABLE_STATIC=ON
make -j$(nproc)