#!/bin/bash

# 创建并进入 build 目录，每次都会删除之前的文件
mkdir -p build 
cd build
rm -rf *

# 运行 CMake 和 Ninja 构建
cmake -G Ninja ..
cmake --build . --target all --config Release -- -j 16

# 获取当前工程所在的盘符
drive_letter=$(pwd | cut -d'/' -f2 | tr '[:lower:]' '[:upper:]')

# 修改 compile_commands.json 文件中的路径
sed -i "s|/c/|C:/|g; s|/d/|D:/|g; s|/e/|E:/|g; s|/f/|F:/|g; s|/g/|G:/|g; s|/h/|H:/|g; s|/i/|I:/|g; s|/j/|J:/|g; s|/k/|K:/|g; s|/l/|L:/|g; s|/m/|M:/|g; s|/n/|N:/|g; s|/o/|O:/|g; s|/p/|P:/|g; s|/q/|Q:/|g; s|/r/|R:/|g; s|/s/|S:/|g; s|/t/|T:/|g; s|/u/|U:/|g; s|/v/|V:/|g; s|/w/|W:/|g; s|/x/|X:/|g; s|/y/|Y:/|g; s|/z/|Z:/|g" compile_commands.json

# 获取 .ioc 文件的前缀
ioc_file=$(basename ../*.ioc .ioc)
elf_file="$ioc_file.elf"
bin_file="$ioc_file.bin"
hex_file="$ioc_file.hex"

# 检查 ELF 文件是否存在
if [ ! -f "$elf_file" ]; then
    echo "Error: ELF file $elf_file not found!"
    exit 1
fi

# 生成二进制文件和 HEX 文件
arm-none-eabi-objcopy -O binary "$elf_file" "$bin_file"
arm-none-eabi-objcopy -O ihex "$elf_file" "$hex_file"

# 检查二进制文件是否生成成功
if [ ! -f "$bin_file" ]; then
    echo "Error: Binary file $bin_file not generated!"
    exit 1
fi

# 检查 HEX 文件是否生成成功
if [ ! -f "$hex_file" ]; then
    echo "Error: HEX file $hex_file not generated!"
    exit 1
fi

# 打印文件大小信息
echo "ELF file size:"
arm-none-eabi-size "$elf_file"

echo "Binary file information:"
file "$bin_file"

echo "HEX file size:"
arm-none-eabi-size "$hex_file"

# 烧录
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "program $hex_file verify reset exit"