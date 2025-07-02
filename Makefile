CXX = g++
CXXFLAGS = -Wall -std=c++17 -Iinclude $(JNI_INCLUDE) -Wno-deprecated-declarations

SRCS = main.cpp
LIBSRC = $(wildcard src/*.cpp)
STATIC_OBJ = $(patsubst src/%,build/static/%, $(LIBSRC:.cpp=.o))
DLL_OBJ = $(patsubst src/%,build/dll/%, $(LIBSRC:.cpp=.o))
MAIN_OBJ = main.o

TARGET = app

ifeq ($(OS),Windows_NT)
    STATIC_LIB = build/static/math.lib
    DLL = build/dll/math.dll
    EXT = .exe
    RUN_CMD = $(TARGET)$(EXT)
    MKDIR = if not exist build\static mkdir build\static & if not exist build\dll mkdir build\dll
    JAVA_HOME = D:/software/Java/jdk21
    JNI_INCLUDE = -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/win32"
    SHARED_FLAGS = -shared
    OPENSSL_DIR = D:/software/DevTools/msys64/mingw64
    OPENSSL_INC = -I$(OPENSSL_DIR)/include
    OPENSSL_LIB = -L$(OPENSSL_DIR)/lib
    INSTALL_DIR = D:/Program Files/YourApp
else
    STATIC_LIB = build/static/libmath.a
    DLL = build/dll/libmath.so
    EXT =
    RUN_CMD = LD_LIBRARY_PATH=build/dll ./$(TARGET)
    MKDIR = mkdir -p build/static build/dll
    JAVA_HOME = /usr/lib/jvm/java-21-openjdk-amd64
    JNI_INCLUDE = -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/linux"
    SHARED_FLAGS = -fPIC -shared
    OPENSSL_INC = -I/usr/include
    OPENSSL_LIB = -L/usr/lib/x86_64-linux-gnu
    PREFIX ?= /usr/local
endif
#需要链接的 OpenSSL 库 ,告诉链接器要链接 libssl 和 libcrypto
# OPENSSL_LIBS = -lssl -lcrypto
OPENSSL_LIBS = -lcrypto

# 更新 CXXFLAGS，自动包含 OpenSSL 头文件
CXXFLAGS += $(OPENSSL_INC)

all: static shared run

prepare_dirs:
	@$(MKDIR)

# 主程序 .o 文件 编译主程序的目标文件，$< 是第一个依赖，即 main.cpp，$@ 是目标，即 main.o
main.o: main.cpp
	$(CXX) $(CXXFLAGS) -DBUILD_STATIC -c $< -o $@

# 静态库和主程序用的 .o 文件 ,-c $<：只编译，不链接，$< 是源文件 ,-o $@：输出目标文件
build/static/%.o: src/%.cpp | prepare_dirs
	$(CXX) $(CXXFLAGS) -DBUILD_STATIC -c $< -o $@

# DLL 用的 .o 文件
build/dll/%.o: src/%.cpp | prepare_dirs
	$(CXX) $(CXXFLAGS) -DBUILD_DLL -c $< -o $@

# ar：静态库打包工具 ,rcs：参数，分别表示 replace、create、index ,$(STATIC_LIB)：输出的静态库文件名（Windows 下是 .lib，Linux 下是 .a） ,$(STATIC_OBJ)：所有要打包进库的 .o 文件
static: $(STATIC_OBJ)
	ar rcs $(STATIC_LIB) $(STATIC_OBJ)

# 构建动态库（DLL / SO）
shared: $(DLL_OBJ)
	$(CXX) $(CXXFLAGS) $(SHARED_FLAGS) $(OPENSSL_LIB) -o $(DLL) $(DLL_OBJ) $(OPENSSL_LIBS)

# 链接主程序（使用静态库） 然后运行程序
run: $(MAIN_OBJ) static
	$(CXX) $(CXXFLAGS) $(OPENSSL_LIB) -o $(TARGET)$(EXT) main.o $(STATIC_LIB) $(OPENSSL_LIBS)
	@echo "+++++++Running(static lib) $(TARGET)$(EXT)..."
	@$(RUN_CMD)

# 这里使用的是 -lmath，链接 libmath.so 或 math.dll
run-shared: $(MAIN_OBJ) shared
	$(CXX) $(CXXFLAGS) $(OPENSSL_LIB) -o $(TARGET)$(EXT) main.o -Lbuild/dll -lmath $(OPENSSL_LIBS)
	@echo "+++++++Running (dynamic lib) $(TARGET)$(EXT) with shared lib..."
ifeq ($(OS),Windows_NT)
	@copy /Y build\dll\math.dll .
endif
	@$(RUN_CMD)

clean:
ifeq ($(OS),Windows_NT)
	@-del /F /Q *.o *.a *.lib *.so *.dll $(TARGET) $(TARGET).exe
	@-del /F /Q src\*.o  build\static\*.o build\dll\*.o build\static\*.lib build\dll\*.dll
else
	@-rm -f *.o *.a *.lib *.so *.dll $(TARGET) $(TARGET).exe
	@-rm -f src/*.o build/static/*.o build/dll/*.o build/static/*.a build/dll/*.so
endif

install:
ifeq ($(OS),Windows_NT)
	@echo Installing to $(INSTALL_DIR) ...
	@if not exist "$(INSTALL_DIR)" mkdir "$(INSTALL_DIR)"
	@copy /Y $(TARGET)$(EXT) "$(INSTALL_DIR)\"
	@if exist "$(DLL)" echo "DLL exists"
	@if exist "$(DLL)" xcopy /Y "$(DLL)" "$(INSTALL_DIR)\"

else
	@echo Installing to $(PREFIX)/bin and $(PREFIX)/lib ...
	@cp -f $(TARGET) $(PREFIX)/bin/ 2>/dev/null || true
	@if [ -f $(STATIC_LIB) ]; then cp -f $(STATIC_LIB) $(PREFIX)/lib/; fi
	@if [ -f $(DLL) ]; then cp -f $(DLL) $(PREFIX)/lib/; fi
endif

uninstall:
ifeq ($(OS),Windows_NT)
	@echo Uninstalling from $(INSTALL_DIR) ...
	@del /F /Q "$(INSTALL_DIR)\$(TARGET)$(EXT)" 2>nul
	@del /F /Q "$(INSTALL_DIR)\math.lib" 2>nul
	@del /F /Q "$(INSTALL_DIR)\math.dll" 2>nul
else
	@echo Uninstalling from $(PREFIX)/bin and $(PREFIX)/lib ...
	@rm -f $(PREFIX)/bin/$(TARGET) $(PREFIX)/lib/libmath.a $(PREFIX)/lib/libmath.so
endif

help:
	@echo "Available targets:"
	@echo "  all         : Build static lib, shared lib, and main program"
	@echo "  static      : Build static library"
	@echo "  shared      : Build shared library"
	@echo "  run         : Link and run main program (static lib)"
	@echo "  run-shared  : Link and run main program (shared lib)"
	@echo "  clean       : Clean all build files and outputs"
	@echo "  install     : Install program and libs to system directory"
	@echo "  uninstall   : Uninstall program and libs"
	@echo "  help        : Show this help message"
