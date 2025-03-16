set -e

cd /c/Users/Admin/Desktop/led_blink/build/cmake/stm32cubemx
/usr/bin/ccmake.exe -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR)
