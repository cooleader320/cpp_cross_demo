#include <jni.h>
#include "com_example_Main.h"  // javac -h 生成的头文件
#include "math.h"

// JNIEXPORT 和 JNICALL 是 JNI 的宏
extern "C" JNIEXPORT jint JNICALL Java_com_example_Main_add(JNIEnv *, jobject, jint a, jint b) 
{
    return add(a, b); // 调用你自己的 C++ 实现
}