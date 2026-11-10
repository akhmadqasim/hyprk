cmake_minimum_required(VERSION 3.27)
project(hyprk-motion VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(HYPRLAND IMPORTED_TARGET hyprland pixman-1 libdrm)

# pure math (no compositor): shared by the plugin and the unit tests
add_library(motioncore STATIC src/Genie.cpp)
set_target_properties(motioncore PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(motioncore PUBLIC src)

if(HYPRLAND_FOUND)
  add_library(hyprkmotion SHARED src/main.cpp src/GenieTransformer.cpp)
  target_link_libraries(hyprkmotion PRIVATE motioncore PkgConfig::HYPRLAND)
  target_compile_options(hyprkmotion PRIVATE -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers)
else()
  message(WARNING "hyprland.pc not found: only building the unit tests (source /mnt/code/hypr-dev/env.sh)")
endif()

enable_testing()
add_executable(motiontests tests/test_genie.cpp)
target_link_libraries(motiontests PRIVATE motioncore)
add_test(NAME motiontests COMMAND motiontests)
