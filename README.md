# Cross Demo - 跨平台C++项目

这是一个演示跨平台C++开发的示例项目，包含静态库和动态库的构建和使用。

## 项目结构

```
cross_demo/
├── app                    # 编译后的可执行文件
├── include/
│   └── math.h            # 数学库头文件（包含跨平台API导出宏）
├── main.cpp              # 主程序源文件
├── Makefile              # 跨平台构建脚本
├── src/
│   └── math.cpp          # 数学库实现
├── math.lib              # Windows静态库
├── math.dll              # Windows动态库
├── libmath.a             # Linux静态库
└── libmath.so            # Linux动态库
```

## 特性

- ✅ **跨平台支持**: Windows (MinGW/MSVC) 和 Unix/Linux
- ✅ **多种库类型**: 静态库和动态库
- ✅ **符号导出控制**: 自动处理API可见性
- ✅ **调试/发布模式**: 支持不同的编译配置
- ✅ **自动化测试**: 构建后自动运行验证
- ✅ **安装/卸载**: 支持系统级安装

## 快速开始

### 1. 基本构建

```bash
# 构建发布版本并运行（默认）
make

# 构建调试版本
make debug

# 仅构建静态库
make static

# 仅构建动态库
make shared
```

### 2. 运行测试

```bash
# 运行测试（静态库和动态库版本）
make test

# 使用静态库运行
make run

# 使用动态库运行
make run-shared
```

### 3. 安装和卸载

```bash
# 安装到系统（默认 /usr/local）
make install

# 安装到指定路径
make PREFIX=/opt install

# 卸载
make uninstall
```

### 4. 清理

```bash
# 清理构建产物
make clean

# 深度清理（包括安装文件）
make distclean
```

## 构建目标详解

| 目标 | 描述 |
|------|------|
| `all` | 构建发布版本并运行（默认目标） |
| `debug` | 构建调试版本（-g -O0 -DDEBUG） |
| `release` | 构建发布版本（-O2 -DNDEBUG） |
| `static` | 仅构建静态库 |
| `shared` | 仅构建动态库 |
| `run` | 使用静态库构建并运行 |
| `run-shared` | 使用动态库构建并运行 |
| `test` | 运行测试 |
| `install` | 安装到系统 |
| `uninstall` | 从系统卸载 |
| `clean` | 清理构建产物 |
| `distclean` | 深度清理 |
| `help` | 显示帮助信息 |

## 环境变量

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `CXX` | `g++` | C++编译器 |
| `CXXFLAGS` | `-Wall -Wextra -std=c++17 -Iinclude` | 编译选项 |
| `PREFIX` | `/usr/local` | 安装路径 |

## 跨平台特性

### Windows 平台
- 使用 `math.dll` 和 `math.lib`
- 自动设置 PATH 环境变量
- 支持 MinGW 和 MSVC 编译器

### Unix/Linux 平台
- 使用 `libmath.so` 和 `libmath.a`
- 自动设置 LD_LIBRARY_PATH
- 支持 GCC 和 Clang 编译器

## API 导出宏

头文件 `include/math.h` 包含跨平台的API导出宏：

```cpp
// Windows: __declspec(dllexport/dllimport)
// Linux: __attribute__((visibility("default")))
API int add(int a, int b);
```

## 示例输出

```bash
$ make
编译库文件: src/math.cpp
构建静态库: math.lib
构建动态库: math.dll
编译主程序: main.cpp
链接静态库版本...
+++++++运行 app.exe...
2 + 3 = 5
```

## 故障排除

### 常见问题

1. **编译错误**: 确保安装了 C++ 编译器（g++ 或 clang++）
2. **运行时错误**: Windows 下确保 DLL 在 PATH 中，Linux 下确保 .so 在 LD_LIBRARY_PATH 中
3. **权限错误**: 安装时可能需要管理员权限

### 调试技巧

```bash
# 查看详细的编译命令
make V=1

# 使用不同的编译器
make CXX=clang++

# 添加自定义编译选项
make CXXFLAGS="-Wall -Wextra -std=c++17 -Iinclude -DDEBUG"
```

## 扩展项目

要添加新的源文件：

1. 在 `SRCS` 变量中添加新的 `.cpp` 文件
2. 在 `LIBSRC` 变量中添加库源文件
3. 更新头文件依赖关系

## 许可证

本项目采用 MIT 许可证。 