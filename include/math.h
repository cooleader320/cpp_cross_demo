#pragma once

// 跨平台导出符号宏定义：用于控制函数/类在静态库和动态库中的可见性
#if defined(_WIN32) || defined(__CYGWIN__)

  #if defined(BUILD_DLL)
    // 编译动态库（DLL）时，导出符号
    #define API __declspec(dllexport)

  #elif defined(BUILD_STATIC)
    // 编译静态库时，不需要导出符号
    #define API

  #else
    // 客户端使用 DLL 时，导入符号
    #define API __declspec(dllimport)

  #endif

#else

  #if defined(BUILD_DLL)
    // 编译共享库（.so 或 .dylib）时，显式标记导出符号（需配合 -fvisibility=hidden）
    #define API __attribute__((visibility("default")))

  #else
    // 静态库或未开启隐藏符号控制时，不需特殊处理
    #define API

  #endif

#endif

// 函数声明
API int add(int a, int b);