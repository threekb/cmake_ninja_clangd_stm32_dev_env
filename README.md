# 必要文件
1. `./vscode/setting.json`
    > 在这个文件里可以自行修改编译器路径，以下为示例（如果不懂如何配置，照搬即可，即在`C`盘下创建`Tooclchain`文件夹，再将解压后的编译器放到这个文件夹中即可）
> 
 ```yaml
{
    "clangd.arguments": [
      "--query-driver=C:/Toolchain/arm-gnu-toolchain-14.2.rel1-mingw-w64-i686-arm-none-eabi/bin/arm-none-eabi-gcc.exe",  // 指定编译器路径
      "--clang-tidy"
    ]
  }
```
2. `.clangd`
   > 配置这个文件可以修改工程编译时默认链接的标准库（例如`<math.h>`和`<stdio.h>`头文件），若工程里不做添加，则会默认链接到别的标准库，例如`msvc`或者`mingw64`
   > 
   > 如果不会配置，就将编译器的位置与示例同步即可
```yaml
CompileFlags:
  Add:
    - --target=arm-none-eabi          # 指定目标架构
    - -IC:/Toolchain/arm-gnu-toolchain-14.2.rel1-mingw-w64-i686-arm-none-eabi/arm-none-eabi/include  # ARM-GCC头文件路径
    - -IC:/Toolchain/arm-gnu-toolchain-14.2.rel1-mingw-w64-i686-arm-none-eabi/lib/gcc/arm-none-eabi/14.2.1/include  # GCC库头文件
  CompilationDatabase: .              # 指向compile_commands.json
```
3. `/cmake/gcc-arm-none-eabi.cmake`
   > 其实这个文件中只需要添加以下命令到文件结尾处即可
```cmake
# 有中文注释的部分，是cubemx不会自动生成的，需要手动添加
set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -u _printf_float")  # 支持 printf 函数打印浮点数
set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -lm")  # 链接数学库 libm
set(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections,--no-warn-rwx-segments")  # 取消 rwx 段的警告
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-parameter")  # 忽略 C 代码中未使用参数的警告
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-parameter")  # 忽略 C++ 代码中未使用参数的警告
```
4. `/core/src/usart.c`
   > 注意这个文件中的用户代码区中的以下代码，这段代码用于处理串口重定向

   > `main`函数里使用`printf`函数时，需要添加头文件`<stdio.h>`

```c
int _write (int fd, char *pBuffer, int size)
{
  for (int i = 0; i < size; i++)
  {
    while((USART1->SR&0X40)==0);//等待上一次串口数据发送完成
    USART1->DR = (uint8_t) pBuffer[i];    //写DR,串口1将发送数据
  }
  return size;
}
```
5. 其余文件可参考具体实现，考虑要不要添加到自己的工程里
