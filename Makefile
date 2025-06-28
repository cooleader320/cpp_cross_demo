CXX = g++
CXXFLAGS = -Wall -std=c++17 -Iinclude $(JNI_INCLUDE)

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
else
    STATIC_LIB = build/static/libmath.a
    DLL = build/dll/libmath.so
    EXT =
    RUN_CMD = LD_LIBRARY_PATH=build/dll ./$(TARGET)
    MKDIR = mkdir -p build/static build/dll
    JAVA_HOME = /usr/lib/jvm/java-21-openjdk-amd64
    JNI_INCLUDE = -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/linux"
    SHARED_FLAGS = -fPIC -shared
endif

all: static shared run

prepare_dirs:
	@$(MKDIR)

# 主程序 .o 文件 编译主程序的目标文件，$< 是第一个依赖，即 main.cpp，$@ 是目标，即 main.o
main.o: main.cpp
	$(CXX) $(CXXFLAGS) -DBUILD_STATIC -c $< -o $@

# 静态库和主程序用的 .o 文件
build/static/%.o: src/%.cpp | prepare_dirs
	$(CXX) $(CXXFLAGS) -DBUILD_STATIC -c $< -o $@

# DLL 用的 .o 文件
build/dll/%.o: src/%.cpp | prepare_dirs
	$(CXX) $(CXXFLAGS) -DBUILD_DLL -c $< -o $@

# 构建静态库 .a 或 .lib
static: $(STATIC_OBJ)
	ar rcs $(STATIC_LIB) $(STATIC_OBJ)

# 构建动态库（DLL / SO）
shared: $(DLL_OBJ)
	$(CXX) $(CXXFLAGS) $(SHARED_FLAGS) -o $(DLL) $(DLL_OBJ)

# 链接主程序（使用静态库） 然后运行程序
run: $(MAIN_OBJ) static
	$(CXX) $(CXXFLAGS) -o $(TARGET)$(EXT) main.o $(STATIC_LIB)
	@echo "+++++++Running(static lib) $(TARGET)$(EXT)..."
	@$(RUN_CMD)

# 这里使用的是 -lmath，链接 libmath.so 或 math.dll
run-shared: $(MAIN_OBJ) shared
	$(CXX) $(CXXFLAGS) -o $(TARGET)$(EXT) main.o -Lbuild/dll -lmath
	@echo "+++++++Running (dynamic lib) $(TARGET)$(EXT) with shared lib..."
ifeq ($(OS),Windows_NT)
	@copy /Y build\dll\math.dll .
endif
	@$(RUN_CMD)

clean:
ifeq ($(OS),Windows_NT)
	@-del /F /Q *.o *.a *.lib *.so *.dll $(TARGET).exe
	@-del /F /Q src\*.o  build\static\*.o build\dll\*.o build\static\*.lib build\dll\*.dll
else
	@-rm -f *.o *.a *.lib *.so *.dll $(TARGET)
	@-rm -f src/*.o build/static/*.o build/dll/*.o build/static/*.a build/dll/*.so
endif

install:
ifeq ($(OS),Windows_NT)
	@echo Installing to C:\Program Files\YourApp ...
	@if not exist "C:\Program Files\YourApp" mkdir "C:\Program Files\YourApp"
	@copy /Y $(TARGET)$(EXT) "C:\Program Files\YourApp\"
	@if exist $(STATIC_LIB) copy /Y $(STATIC_LIB) "C:\Program Files\YourApp\"
	@if exist $(DLL) copy /Y $(DLL) "C:\Program Files\YourApp\"
else
	@echo Installing to /usr/local/bin and /usr/local/lib ...
	@cp -f $(TARGET) /usr/local/bin/ 2>/dev/null || true
	@if [ -f $(STATIC_LIB) ]; then cp -f $(STATIC_LIB) /usr/local/lib/; fi
	@if [ -f $(DLL) ]; then cp -f $(DLL) /usr/local/lib/; fi
endif

uninstall:
ifeq ($(OS),Windows_NT)
	@echo Uninstalling from C:\Program Files\YourApp ...
	@del /F /Q "C:\Program Files\YourApp\$(TARGET)$(EXT)" 2>nul
	@del /F /Q "C:\Program Files\YourApp\math.lib" 2>nul
	@del /F /Q "C:\Program Files\YourApp\math.dll" 2>nul
else
	@echo Uninstalling from /usr/local/bin and /usr/local/lib ...
	@rm -f /usr/local/bin/$(TARGET) /usr/local/lib/libmath.a /usr/local/lib/libmath.so
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
