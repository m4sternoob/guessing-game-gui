@echo off
REM Build script for Windows
REM Prerequisites: 
REM 1. Install Visual Studio 2022 with "Desktop development with C++" workload
REM 2. Install vcpkg: git clone https://github.com/microsoft/vcpkg && .\vcpkg\bootstrap-vcpkg.bat
REM 3. Install SDL2: .\vcpkg\vcpkg install sdl2:x64-windows
REM 4. Add vcpkg to PATH or set VCPKG_ROOT environment variable

mkdir build 2>nul
cd build

REM Configure with CMake using vcpkg toolchain
cmake .. -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake -G "Visual Studio 17 2022" -A x64

REM Build
cmake --build . --config Release

REM The executable will be at build/Release/GuessingGame.exe
echo.
echo Build complete! Run: .\Release\GuessingGame.exe
pause