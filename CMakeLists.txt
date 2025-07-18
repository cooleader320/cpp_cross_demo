cmake_minimum_required(VERSION 3.10)
project(cpp_cross_demo LANGUAGES CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -g -O0 -Wno-deprecated-declarations")

# 包含头文件目录
include_directories(${CMAKE_SOURCE_DIR}/include)

# ===================== JNI 配置 =====================
# 自动检测 JAVA_HOME，或手动指定
if(NOT DEFINED JAVA_HOME)
    if(DEFINED ENV{JAVA_HOME})
        set(JAVA_HOME $ENV{JAVA_HOME})
    else()
        if(WIN32)
            set(JAVA_HOME "D:/software/Java/jdk21") # 如有不同请手动修改
        else()
            set(JAVA_HOME "/usr/lib/jvm/java-21-openjdk-amd64")
        endif()
    endif()
endif()
# 添加 JNI 头文件目录
if(WIN32)
    include_directories("${JAVA_HOME}/include" "${JAVA_HOME}/include/win32")
else()
    include_directories("${JAVA_HOME}/include" "${JAVA_HOME}/include/linux")
endif()

# ===================== OpenSSL 配置 =====================
# 你可以根据实际情况修改 OPENSSL_ROOT_DIR
if(MSVC)
    # MSVC (Visual Studio) 下，需使用官方预编译或自编译的 OpenSSL
    set(OPENSSL_ROOT_DIR "C:/local/openssl") # 请根据实际路径修改
    include_directories("${OPENSSL_ROOT_DIR}/include")
    link_directories("${OPENSSL_ROOT_DIR}/lib")
    set(OPENSSL_CRYPTO_LIB "libcrypto.lib")
elseif(MINGW)
    # MinGW 下，使用 mingw-w64 提供的 OpenSSL
    set(OPENSSL_ROOT_DIR "D:/software/DevTools/msys64/mingw64") # 请根据实际路径修改
    include_directories("${OPENSSL_ROOT_DIR}/include")
    link_directories("${OPENSSL_ROOT_DIR}/lib")
    set(OPENSSL_CRYPTO_LIB "crypto")
else()
    # Linux 下，通常系统自带 OpenSSL
    set(OPENSSL_ROOT_DIR "/usr")
    include_directories("${OPENSSL_ROOT_DIR}/include")
    link_directories("${OPENSSL_ROOT_DIR}/lib" "${OPENSSL_ROOT_DIR}/lib/x86_64-linux-gnu")
    set(OPENSSL_CRYPTO_LIB "crypto")
endif()

# ===================== 源文件收集 =====================
file(GLOB SRC_LIB "src/*.cpp")
set(SRC_MAIN main.cpp)

# ===================== 输出目录结构设置 =====================
# 获取当前构建类型（Debug/Release）
if(CMAKE_CONFIGURATION_TYPES)
    # 多配置生成器（如 Visual Studio）
    set(OUT_CONFIG "$<CONFIG>")
else()
    # 单配置生成器（如 Makefile、Ninja）
    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug)
    endif()
    set(OUT_CONFIG "${CMAKE_BUILD_TYPE}")
endif()
set(OUT_ROOT "${CMAKE_BINARY_DIR}/${OUT_CONFIG}")
set(BIN_DIR   "${OUT_ROOT}/bin")
set(OBJ_DIR   "${OUT_ROOT}/obj")
set(LIB_STATIC_DIR "${OUT_ROOT}/lib/static")
set(LIB_SHARED_DIR "${OUT_ROOT}/lib/shared")

# ===================== 静态库目标 =====================
add_library(math_static STATIC ${SRC_LIB})
set_target_properties(math_static PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${LIB_STATIC_DIR}"
    LIBRARY_OUTPUT_DIRECTORY "${LIB_STATIC_DIR}"
    RUNTIME_OUTPUT_DIRECTORY "${LIB_STATIC_DIR}"
    OUTPUT_NAME "math_static"
    # 对象文件输出目录（部分生成器支持）
    OBJECT_OUTPUT_DIRECTORY "${OBJ_DIR}/math_static"
)
target_compile_definitions(math_static PRIVATE BUILD_STATIC)
target_link_libraries(math_static PRIVATE ${OPENSSL_CRYPTO_LIB})

# ===================== 动态库目标 =====================
add_library(math_shared SHARED ${SRC_LIB})
set_target_properties(math_shared PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${LIB_SHARED_DIR}"
    LIBRARY_OUTPUT_DIRECTORY "${LIB_SHARED_DIR}"
    RUNTIME_OUTPUT_DIRECTORY "${LIB_SHARED_DIR}"
    OUTPUT_NAME "math_shared"
    OBJECT_OUTPUT_DIRECTORY "${OBJ_DIR}/math_shared"
)
target_compile_definitions(math_shared PRIVATE BUILD_DLL)
target_link_libraries(math_shared PRIVATE ${OPENSSL_CRYPTO_LIB})

# ===================== 主程序目标 =====================
add_executable(app_static ${SRC_MAIN})
target_compile_definitions(app_static PRIVATE BUILD_STATIC)
target_link_libraries(app_static PRIVATE math_static ${OPENSSL_CRYPTO_LIB})
set_target_properties(app_static PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${BIN_DIR}"
     OUTPUT_NAME "app_static"
    # OUTPUT_NAME $<$<PLATFORM_ID:Windows>:app_static.exe>$<$<NOT:$<PLATFORM_ID:Windows>>:app_static>

)

add_executable(app_shared ${SRC_MAIN})
target_link_libraries(app_shared PRIVATE math_shared ${OPENSSL_CRYPTO_LIB})
set_target_properties(app_shared PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${BIN_DIR}"
    OUTPUT_NAME "app_shared"
    # OUTPUT_NAME $<$<PLATFORM_ID:Windows>:app_shared.exe>$<$<NOT:$<PLATFORM_ID:Windows>>:app_shared>
 
)

# ===================== 运行时设置 =====================
# Windows 下输出 app.exe，Linux 下输出 app
# 删除或注释掉这段
# set_target_properties(app PROPERTIES OUTPUT_NAME "app.exe")
# 或
# set_target_properties(app PROPERTIES OUTPUT_NAME "app")

# ===================== 运行目标 =====================
if(WIN32)
    add_custom_target(run_app_static
        COMMAND cmd /C "chcp 65001 >nul && ${BIN_DIR}/app_static.exe"
        DEPENDS app_static
        WORKING_DIRECTORY "${BIN_DIR}"
        COMMENT "运行 app_static.exe (静态链接，UTF-8 编码)"
    )
    add_custom_target(run_app_shared
        COMMAND cmd /C "chcp 65001 >nul && set PATH=${LIB_SHARED_DIR};%PATH% && ${BIN_DIR}/app_shared.exe"
        DEPENDS app_shared
        WORKING_DIRECTORY "${BIN_DIR}"
        COMMENT "运行 app_shared.exe (动态链接，自动设置 DLL 路径，UTF-8 编码)"
    )
else()
    add_custom_target(run_app_static
        COMMAND "${BIN_DIR}/app_static"
        DEPENDS app_static
        WORKING_DIRECTORY "${BIN_DIR}"
        COMMENT "运行 app_static (静态链接)"
    )
    add_custom_target(run_app_shared
          COMMAND env LC_ALL=en_US.UTF-8 LD_LIBRARY_PATH="${LIB_SHARED_DIR}:\$LD_LIBRARY_PATH" ${BIN_DIR}/app_shared
        DEPENDS app_shared
        WORKING_DIRECTORY "${BIN_DIR}"
        COMMENT "运行 app_shared (动态链接，自动设置 LD_LIBRARY_PATH，UTF-8 编码)"
    )
endif()

# ===================== 安装规则 =====================
include(GNUInstallDirs)
install(TARGETS app_static app_shared math_static math_shared
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# ===================== 使用说明 =====================
# 1. 如需自定义 OpenSSL 路径，请修改 OPENSSL_ROOT_DIR 及相关 lib 名称
# 2. 如需自定义 JAVA_HOME，请设置环境变量或直接修改上方 JAVA_HOME 变量
# 3. 构建命令：
#    mkdir build
#    cd build
#    cmake .. -G "Visual Studio 17 2022"   # VS2022
#    cmake .. -G "MinGW Makefiles"         # MinGW
#    cmake ..                              # Linux
# 4.用 CMake 生成的构建系统，在当前目录下自动编译并链接你的项目，生成所有产物
#    cmake --build .
# 5. 你可以在 CMake GUI 或命令行中手动指定 -DOPENSSL_ROOT_DIR=... -DJAVA_HOME=... 
# ===================== 可用 CMake Target 及说明 =====================
# 你可以使用如下命令（在 build 目录下）来执行对应目标：
#
# 1. 构建所有目标（默认）:
#    cmake --build .
#
# 2. 构建主程序 app_static（静态链接）:
#    cmake --build . --target app_static
#
# 3. 构建主程序 app_shared（动态链接）:
#    cmake --build . --target app_shared
#
# 4. 构建静态库 math_static:
#    cmake --build . --target math_static
#
# 5. 构建动态库 math_shared:
#    cmake --build . --target math_shared
#
# 6. 运行静态链接程序（自动切换到 bin 目录，Windows 下为 app_static.exe，Linux 下为 app_static）:
#    cmake --build . --target run_app_static
#
# 7. 运行动态链接程序（自动设置 DLL/LD_LIBRARY_PATH 路径，切换到 bin 目录）:
#    cmake --build . --target run_app_shared
#
# 8. 安装程序和库到系统目录（可用 -DCMAKE_INSTALL_PREFIX=... 指定安装路径）:
#    cmake --build . --target install
#
# 9. 清理构建产物（如有 clean 目标）:
#    cmake --build . --target clean
#
# 10. 查看帮助信息（列出所有可用目标）:
#     cmake --build . --target cmake_help
#
# 说明：
# - 你可以在 CMake GUI 或命令行中手动指定 -DOPENSSL_ROOT_DIR=... -DJAVA_HOME=... 等变量。
# - 运行目标 run_app_static 和 run_app_shared 会自动设置编码和依赖库路径，适配 Windows/Linux。
# - install 目标会将可执行文件和库安装到系统指定目录。
# - clean 目标会清理构建产物（如支持）。


# ===================== 帮助信息目标 =====================
add_custom_target(cmake_help
    COMMAND ${CMAKE_COMMAND} -E echo "可用目标:"
    COMMAND ${CMAKE_COMMAND} -E echo "  app           : 主程序"
    COMMAND ${CMAKE_COMMAND} -E echo "  math_static   : 静态库"
    COMMAND ${CMAKE_COMMAND} -E echo "  math_shared   : 动态库"
    COMMAND ${CMAKE_COMMAND} -E echo "  install       : 安装程序和库"
    COMMAND ${CMAKE_COMMAND} -E echo "  clean         : 清理"
)

message(STATUS "C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "AR: ${CMAKE_AR}")
message(STATUS "RANLIB: ${CMAKE_RANLIB}")
message(STATUS "LINKER: ${CMAKE_LINKER}")
message(STATUS "MAKE_PROGRAM: ${CMAKE_MAKE_PROGRAM}") 