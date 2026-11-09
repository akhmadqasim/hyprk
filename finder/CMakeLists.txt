cmake_minimum_required(VERSION 3.21)
project(hyprk-finder LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick)

add_executable(hyprk-finder src/main.cpp src/fileops.cpp src/fileops.h src/thumbnails.cpp src/thumbnails.h src/sysicons.cpp src/sysicons.h)
target_link_libraries(hyprk-finder PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick)
# QML is loaded from the source tree so UI changes need no rebuild.
target_compile_definitions(hyprk-finder PRIVATE
    FINDER_QML_DIR="${CMAKE_CURRENT_SOURCE_DIR}/qml"
    FINDER_FONT_DIR="${CMAKE_CURRENT_SOURCE_DIR}/../themes/fonts"
    FINDER_ICON_DIR="${CMAKE_CURRENT_SOURCE_DIR}/../themes/icons/system")

# Logic tests for the native helpers (not built by default): cmake --build build --target finder-tests
add_executable(finder-tests EXCLUDE_FROM_ALL tests/fileops_test.cpp src/fileops.cpp src/fileops.h)
target_link_libraries(finder-tests PRIVATE Qt6::Core)
