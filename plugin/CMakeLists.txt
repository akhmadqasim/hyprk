cmake_minimum_required(VERSION 3.27)
project(hyprk-liquidglass VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# embed the shader source so the .so is self-contained
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/shaders/liquidglass.frag LG_FRAG)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/Shaders.hpp.in ${CMAKE_CURRENT_BINARY_DIR}/gen/Shaders.hpp @ONLY)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS shaders/liquidglass.frag)

# pure logic, no Hyprland: shared by the plugin and the unit tests
add_library(lgcore STATIC src/Shape.cpp src/Params.cpp)
set_target_properties(lgcore PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(lgcore PUBLIC src)

find_package(PkgConfig REQUIRED)
pkg_check_modules(HYPRLAND IMPORTED_TARGET hyprland pixman-1 libdrm)

if(HYPRLAND_FOUND)
  add_library(liquidglass SHARED src/main.cpp src/Config.cpp src/GlassElement.cpp)
  target_include_directories(liquidglass PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/gen)
  target_link_libraries(liquidglass PRIVATE lgcore PkgConfig::HYPRLAND)
  target_compile_options(liquidglass PRIVATE -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers)
else()
  message(WARNING "hyprland.pc not found: only building the unit tests (source /mnt/code/hypr-dev/env.sh)")
endif()

enable_testing()
add_executable(lgtests tests/test_main.cpp)
target_link_libraries(lgtests PRIVATE lgcore)
add_test(NAME lgtests COMMAND lgtests)
