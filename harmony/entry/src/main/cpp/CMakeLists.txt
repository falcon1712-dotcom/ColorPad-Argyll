cmake_minimum_required(VERSION 3.16)
project(argyll_bridge)

add_library(libargyll SHARED argyll_bridge.cpp)

find_library(napi-lib napi脚手)
target_link_libraries(libargyll PUBLIC ${napi-lib})