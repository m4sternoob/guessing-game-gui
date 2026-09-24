cmake_minimum_required(VERSION 3.16)
project(GuessingGameGUI LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Platform-specific settings
if(WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_WIN32_WINNT=0x0601")
    # Windows: link against SDL2main for proper entry point
    set(SDL2_LIBRARIES SDL2 SDL2main)
elseif(APPLE)
    # macOS: use Cocoa framework
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mmacosx-version-min=10.13")
    find_library(COCOA Cocoa)
    find_library(IOKIT IOKit)
    find_library(COREVIDEO CoreVideo)
    find_library(COREFOUNDATION CoreFoundation)
    find_library(GAMECONTROLLER GameController)
    set(SDL2_LIBRARIES ${COCOA} ${IOKIT} ${COREVIDEO} ${COREFOUNDATION} ${GAMECONTROLLER})
else()
    # Linux
    find_library(DL dl)
    find_library(PTHREAD pthread)
    find_library(M m)
    set(SDL2_LIBRARIES ${DL} ${PTHREAD} ${M})
endif()

# Find SDL2 using sdl2-config for includes
execute_process(
    COMMAND sdl2-config --cflags
    OUTPUT_VARIABLE SDL2_CFLAGS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Parse include flags
string(REGEX MATCHALL "-I[^ ]+" SDL2_INCLUDE_FLAGS "${SDL2_CFLAGS}")
foreach(flag ${SDL2_INCLUDE_FLAGS})
    string(REGEX REPLACE "^-I" "" path "${flag}")
    list(APPEND SDL2_INCLUDE_DIRS "${path}")
endforeach()

# Also add standard SDL2 include path
list(APPEND SDL2_INCLUDE_DIRS "/opt/homebrew/include/SDL2")

# Include directories
include_directories(${SDL2_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/imgui)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/imgui/backends)

# Source files
set(SOURCES
    main.cpp
    imgui/imgui.cpp
    imgui/imgui_draw.cpp
    imgui/imgui_tables.cpp
    imgui/imgui_widgets.cpp
    imgui/backends/imgui_impl_sdl2.cpp
    imgui/backends/imgui_impl_sdlrenderer2.cpp
)

add_executable(GuessingGame ${SOURCES})

# Link with SDL2 using sdl2-config --libs output
target_link_libraries(GuessingGame "/opt/homebrew/lib/libSDL2main.a" "/opt/homebrew/lib/libSDL2.dylib")
target_link_libraries(GuessingGame "-framework Cocoa" "-framework IOKit" "-framework CoreVideo" "-framework CoreFoundation" "-framework GameController")

# Platform-specific linker settings
if(WIN32)
    # Windows: use WinMain entry point
    set_target_properties(GuessingGame PROPERTIES
        WIN32_EXECUTABLE TRUE
        LINK_FLAGS "/SUBSYSTEM:WINDOWS"
    )
elseif(APPLE)
    # macOS: create app bundle
    set_target_properties(GuessingGame PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
    )
endif()

# Install target
install(TARGETS GuessingGame DESTINATION bin)

# Console version (original foundation)
add_subdirectory(console)