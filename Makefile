CXX = g++
CXXFLAGS = -Wall -std=c++17 -Iinclude

SRCS = main.cpp
LIBSRC = src/math.cpp
OBJ = $(SRCS:.cpp=.o)
LIBOBJ = math.o

TARGET = app

ifeq ($(OS),Windows_NT)
    DLL = math.dll
    STATIC_LIB = math.lib
    SHARED_FLAGS = -shared -DBUILD_DLL
    RM = del /F /Q
    RUN_CP = cmd /C " echo DLL copying... &&  copy /Y $(DLL) . > NUL"
    EXT = .exe
    RUN_CMD = $(TARGET)$(EXT)
else
    DLL = libmath.so
    STATIC_LIB = libmath.a
    SHARED_FLAGS = -fPIC -shared
    RM = rm -f
    RUN_CP = cp $(DLL) .
    EXT =
    RUN_CMD = LD_LIBRARY_PATH=. ./$(TARGET)
endif

all: static shared run

math.o: $(LIBSRC)
	$(CXX) $(CXXFLAGS) -DBUILD_STATIC -c $(LIBSRC) -o math.o

static: math.o
	ar rcs $(STATIC_LIB) math.o

shared: math.o
	$(CXX) $(CXXFLAGS) $(SHARED_FLAGS) -o $(DLL) math.o


run: $(SRCS) $(STATIC_LIB)
	$(CXX) $(CXXFLAGS) -DBUILD_STATIC -c $(SRCS)
	$(CXX) $(CXXFLAGS) -o $(TARGET)$(EXT) main.o $(STATIC_LIB)

	@echo "+++++++Running $(TARGET)$(EXT)..."
	@$(RUN_CMD)




run-shared: $(SRCS) shared
	$(CXX) $(CXXFLAGS) -c $(SRCS)
	$(CXX) $(CXXFLAGS) -o $(TARGET)$(EXT) main.o -L. -lmath
	-$(RUN_CP)
	@$(RUN_CMD)



clean:
	-$(RM) *.o *.a *.lib *.so *.dll $(TARGET).exe $(TARGET)$(EXT)
