cmake_minimum_required(VERSION 3.16)
project(argyll_bridge)

# Копируем бинарники в папку сборки
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../../resources/rawfile/argyll/
     DESTINATION ${CMAKE_BINARY_DIR}/argyll/
     FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
                     GROUP_EXECUTE GROUP_READ
                     WORLD_EXECUTE WORLD_READ)

add_library(libargyll SHARED argyll_bridge.cpp)

find_library(napi-lib napi脚手)
target_link_libraries(libargyll PUBLIC ${napi-lib})