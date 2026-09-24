cmake_minimum_required(VERSION 3.16)
project(GuessingGameConsole LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(guessing_game_console guessing_game.cpp)

# Install target
install(TARGETS guessing_game_console DESTINATION bin)