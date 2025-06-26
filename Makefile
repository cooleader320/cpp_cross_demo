CXX = g++
CXXFLAGS = -Wall -std=c++17 -Iinclude $(JNI_INCLUDE)

SRCS = main.cpp
LIBSRC = $(wildcard src/*.cpp)
STATIC_OBJ = $(LIBSRC:.cpp=.o)
DLL_OBJ = $(patsubst src/%,build/dll/%, $(LIBSRC:.cpp=.o))
OBJ = $(SRCS:.cpp=.o)

TARGET = app

ifeq ($(OS),Windows_NT)
    DLL = math.dll
    STATIC_LIB = math.lib
    SHARED_FLAGS = -shared
    RM = del /F /Q
    RUN_CP = cmd /C " echo DLL copying... &&  copy /Y $(DLL) . > NUL"
    EXT = .exe
    RUN_CMD = $(TARGET)$(EXT)
    JAVA_HOME = D:/software/Java/jdk21
    JNI_INCLUDE = -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/win32"
    MKDIR = if not exist build\dll mkdir build\dll
else
    DLL = libmath.so
    STATIC_LIB = libmath.a
    SHARED_FLAGS = -fPIC -shared
    RM = rm -f
    RUN_CP = cp $(DLL) .
    EXT =
    RUN_CMD = LD_LIBRARY_PATH=. ./$(TARGET)
    JAVA_HOME = /usr/lib/jvm/java-21-openjdk-amd64
    JNI_INCLUDE = -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/linux"
    MKDIR = mkdir -p build/dll
endif

all: static shared run

prepare_dirs:
	@$(MKDIR)

# 静态库、主程序用的 .o 文件（全部加 -DBUILD_STATIC）
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -DBUILD_STATIC -c $< -o $@

# DLL 用的 .o 文件
build/dll/%.o: src/%.cpp | prepare_dirs
	$(CXX) $(CXXFLAGS) -DBUILD_DLL -c $< -o $@

static: $(STATIC_OBJ)
	ar rcs $(STATIC_LIB) $(STATIC_OBJ)

shared: $(DLL_OBJ)
	$(CXX) $(CXXFLAGS) $(SHARED_FLAGS) -o $(DLL) $(DLL_OBJ)

run: $(OBJ) static
	$(CXX) $(CXXFLAGS) -o $(TARGET)$(EXT) main.o $(STATIC_LIB)
	@echo "+++++++Running $(TARGET)$(EXT)..."
	@$(RUN_CMD)

run-shared: $(OBJ) shared
	$(CXX) $(CXXFLAGS) -o $(TARGET)$(EXT) main.o -L. -lmath
	-$(RUN_CP)
	@$(RUN_CMD)

clean:
ifeq ($(OS),Windows_NT)
	@-$(RM) *.o *.a *.lib *.so *.dll $(TARGET).exe $(TARGET)$(EXT) 2>nul
	@-$(RM) src\\*.o 2>nul
	@-$(RM) build\\dll\\*.o 2>nul
else
	@-$(RM) *.o *.a *.lib *.so *.dll $(TARGET).exe $(TARGET)$(EXT)
	@-$(RM) src/*.o
	@-$(RM) build/dll/*.o
endif
