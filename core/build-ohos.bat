@echo off
set OHOS_SDK_ROOT=C:\Huawei\Sdk\ohos-sdk\API-11

if not exist "%OHOS_SDK_ROOT%\native\build\cmake\ohos.toolchain.cmake" (
  echo ERROR: SDK не найден
  exit /b 1
)

mkdir build-ohos-arm64
cd build-ohos-arm64

cmake ../argyllcms ^
  -DCMAKE_TOOLCHAIN_FILE="%OHOS_SDK_ROOT%/native/build/cmake/ohos.toolchain.cmake" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=./install ^
  -DENABLE_STATIC=ON ^
  -DCMAKE_EXE_LINKER_FLAGS="-static"

cmake --build . --config Release --parallel

echo ✓ Сборка завершена!