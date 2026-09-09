cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

add_executable(${BINARY_NAME} WIN32
  "main.cpp"
)

apply_standard_settings(${BINARY_NAME})
