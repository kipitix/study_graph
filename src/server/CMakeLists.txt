cmake_minimum_required(VERSION 3.28)
project(HealthCheckServer)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Boost packages
find_package(Boost 1.66 REQUIRED COMPONENTS system)

# Add executable
add_executable(study_graph_server main.cpp)

# Link Boost libraries
target_link_libraries(study_graph_server
    Boost::system
    pthread
)

# Set compiler flags
target_compile_options(study_graph_server PRIVATE -Wall -Wextra)
