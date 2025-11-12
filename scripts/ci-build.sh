#!/bin/bash
set -e

# CI-скрипт для GitHub Actions: сборка Argyll под HarmonyOS ARM64

# 1. Проверяем переменные окружения
if [ -z "$OHOS_SDK_ROOT" ]; then
  echo "ERROR: OHOS_SDK_ROOT не установлен. Укажите путь к HarmonyOS SDK."
  exit 1
fi

# 2. Создаём рабочую папку
WORK_DIR="$HOME/argyll-build"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 3. Клонируем ArgyllCMS (официальный репозиторий)
git clone --depth 1 --branch v3.3.0 https://github.com/argyllcms/argyllcms.git
cd argyllcms

# 4. Применяем патчи для HarmonyOS
git apply "$GITHUB_WORKSPACE/core/patches/libusb-harmonyos.patch"
git apply "$GITHUB_WORKSPACE/core/patches/argyll-paths.patch"

# 5. Собираем статические библиотеки (libusb, libtiff, zlib)
echo "→ Building static libs..."
mkdir -p build-libs && cd build-libs

# libusb 1.0.26 с патчем для HarmonyOS
wget https://github.com/libusb/libusb/releases/download/v1.0.26/libusb-1.0.26.tar.bz2
tar -xjf libusb-1.0.26.tar.bz2
cd libusb-1.0.26
./configure --host=aarch64-linux-ohos \
            --prefix="$WORK_DIR/install" \
            --disable-udev --disable-shared
make -j$(nproc) install
cd ..

# libtiff
wget https://download.osgeo.org/libtiff/tiff-4.4.0.tar.gz
tar -xzf tiff-4.4.0.tar.gz
cd tiff-4.4.0
./configure --host=aarch64-linux-ohos \
            --prefix="$WORK_DIR/install" \
            --disable-shared
make -j$(nproc) install
cd ..

# zlib
wget https://zlib.net/fossils/zlib-1.2.13.tar.gz
tar -xzf zlib-1.2.13.tar.gz
cd zlib-1.2.13
./configure --prefix="$WORK_DIR/install"
make -j$(nproc) install
cd ..

# 6. Собираем Argyll
echo "→ Building Argyll binaries..."
cd ..
export PKG_CONFIG_PATH="$WORK_DIR/install/lib/pkgconfig"
export LDFLAGS="-L$WORK_DIR/install/lib -static"
export CFLAGS="-I$WORK_DIR/install/include -O2"

mkdir -p build-ohos && cd build-ohos
cmake .. -DCMAKE_TOOLCHAIN_FILE="$OHOS_SDK_ROOT/native/build/cmake/ohos.toolchain.cmake" \
         -DCMAKE_BUILD_TYPE=Release \
         -DENABLE_STATIC=ON \
         -DCMAKE_INSTALL_PREFIX="$WORK_DIR/argyll-bin"
make -j$(nproc) install

# 7. Пакуем бинарники в zip-артефакт
echo "→ Packaging..."
cd "$WORK_DIR/argyll-bin/bin"
zip -r "$GITHUB_WORKSPACE/argyll-binaries-ohos-arm64.zip" .

echo "✓ Build complete. Binaries saved to argyll-binaries-ohos-arm64.zip"