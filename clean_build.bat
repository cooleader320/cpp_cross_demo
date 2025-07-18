@echo off
chcp 65001 >nul

cd /d %~dp0
if exist build (
    echo "正在删除 build 目录..."
    del /f /q build\*
    for /d %%i in (build\*) do rd /s /q "%%i"
    @REM rmdir /s /q build
) else (
    echo "正在创建 build 目录..."
    mkdir build
)


