#include <iostream>
#include <string>

// 简单的计算器类
class Calculator {
public:
    // 基本运算
    int add(int a, int b) {
        return a + b;
    }
    
    int subtract(int a, int b) {
        return a - b;
    }
    
    int multiply(int a, int b) {
        return a * b;
    }
    
    double divide(int a, int b) {
        if (b == 0) {
            std::cout << "错误：除数不能为零！" << std::endl;
            return 0;
        }
        return static_cast<double>(a) / b;
    }
};

// 学生信息结构
struct Student {
    std::string name;
    int age;
    double score;
    
    void display() {
        std::cout << "姓名: " << name << ", 年龄: " << age << ", 成绩: " << score << std::endl;
    }
};

int main() {
    std::cout << "=== C++ 入门示例程序 ===" << std::endl;
    
    // 1. 基本数据类型和变量
    std::cout << "\n1. 基本数据类型演示：" << std::endl;
    int number = 42;
    double pi = 3.14159;
    char grade = 'A';
    bool isStudent = true;
    std::string name = "张三";
    
    std::cout << "整数: " << number << std::endl;
    std::cout << "浮点数: " << pi << std::endl;
    std::cout << "字符: " << grade << std::endl;
    std::cout << "布尔值: " << isStudent << std::endl;
    std::cout << "字符串: " << name << std::endl;
    
    // 2. 数组
    std::cout << "\n2. 数组演示：" << std::endl;
    int numbers[5] = {1, 2, 3, 4, 5};
    std::cout << "数组元素: ";
    for (int i = 0; i < 5; i++) {
        std::cout << numbers[i] << " ";
    }
    std::cout << std::endl;
    
    // 3. 条件语句
    std::cout << "\n3. 条件语句演示：" << std::endl;
    int score = 85;
    if (score >= 90) {
        std::cout << "优秀" << std::endl;
    } else if (score >= 80) {
        std::cout << "良好" << std::endl;
    } else if (score >= 70) {
        std::cout << "中等" << std::endl;
    } else if (score >= 60) {
        std::cout << "及格" << std::endl;
    } else {
        std::cout << "不及格" << std::endl;
    }
    
    // 4. 循环
    std::cout << "\n4. 循环演示：" << std::endl;
    std::cout << "for循环: ";
    for (int i = 1; i <= 5; i++) {
        std::cout << i << " ";
    }
    std::cout << std::endl;
    
    std::cout << "while循环: ";
    int j = 1;
    while (j <= 5) {
        std::cout << j << " ";
        j++;
    }
    std::cout << std::endl;
    
    // 5. 函数调用
    std::cout << "\n5. 函数调用演示：" << std::endl;
    Calculator calc;
    int a = 10, b = 3;
    
    std::cout << a << " + " << b << " = " << calc.add(a, b) << std::endl;
    std::cout << a << " - " << b << " = " << calc.subtract(a, b) << std::endl;
    std::cout << a << " * " << b << " = " << calc.multiply(a, b) << std::endl;
    std::cout << a << " / " << b << " = " << calc.divide(a, b) << std::endl;
    
    // 6. 结构体
    std::cout << "\n6. 结构体演示：" << std::endl;
    Student student1 = {"李四", 20, 88.5};
    Student student2 = {"王五", 19, 92.0};
    
    student1.display();
    student2.display();
    
    // 7. 指针基础
    std::cout << "\n7. 指针演示：" << std::endl;
    int value = 100;
    int* ptr = &value;
    
    std::cout << "变量值: " << value << std::endl;
    std::cout << "变量地址: " << &value << std::endl;
    std::cout << "指针存储的地址: " << ptr << std::endl;
    std::cout << "指针指向的值: " << *ptr << std::endl;
    
    // 8. 动态内存分配
    std::cout << "\n8. 动态内存分配演示：" << std::endl;
    int* dynamicArray = new int[3];
    dynamicArray[0] = 10;
    dynamicArray[1] = 20;
    dynamicArray[2] = 30;
    
    std::cout << "动态数组: ";
    for (int i = 0; i < 3; i++) {
        std::cout << dynamicArray[i] << " ";
    }
    std::cout << std::endl;
    
    delete[] dynamicArray;  // 释放内存
    
    // 9. 字符串操作
    std::cout << "\n9. 字符串操作演示：" << std::endl;
    std::string str1 = "Hello";
    std::string str2 = "World";
    std::string result = str1 + " " + str2;
    
    std::cout << "字符串连接: " << result << std::endl;
    std::cout << "字符串长度: " << result.length() << std::endl;
    std::cout << "第一个字符: " << result[0] << std::endl;
    
    // 10. 输入输出
    std::cout << "\n10. 用户输入演示：" << std::endl;
    std::string userName;
    int userAge;
    
    std::cout << "请输入你的姓名: ";
    std::cin >> userName;
    
    std::cout << "请输入你的年龄: ";
    std::cin >> userAge;
    
    std::cout << "你好, " << userName << "! 你今年 " << userAge << " 岁。" << std::endl;
    
    std::cout << "\n=== 程序结束 ===" << std::endl;
    return 0;
} 