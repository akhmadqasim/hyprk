# Trackpad (pixel-delta, scroll-phase) wheel events into RubberBand and a plain Flickable, offscreen.
#   cmake -S ui/tests/wheel -B <build> -G Ninja && cmake --build <build> && QT_QPA_PLATFORM=offscreen <build>/tst_wheel
cmake_minimum_required(VERSION 3.16)
project(hyprk_ui_wheel LANGUAGES CXX)
find_package(Qt6 6.5 REQUIRED COMPONENTS Gui Quick Test)
set(CMAKE_AUTOMOC ON)
add_executable(tst_wheel tst_wheel.cpp)
target_compile_definitions(tst_wheel PRIVATE FIXTURE="${CMAKE_CURRENT_SOURCE_DIR}/view.qml")
target_link_libraries(tst_wheel PRIVATE Qt6::Gui Qt6::Quick Qt6::Test)
