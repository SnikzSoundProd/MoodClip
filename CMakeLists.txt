cmake_minimum_required(VERSION 3.20)
project(MoodClip VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2 QuickShapes Sql)

add_executable(MoodClip WIN32 MACOSX_BUNDLE
    src/main.cpp
    src/core/ProjectManager.cpp
    src/core/Clip.cpp
    src/core/StoryboardModel.cpp
    src/core/StoryboardFrame.cpp
    src/core/AssetLibrary.cpp
    src/core/AssetItem.cpp
    src/core/ExportManager.cpp
)

target_link_libraries(MoodClip PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickShapes
    Qt6::Sql
)

# Copy QML files to build directory for runtime loading
file(COPY src/qml DESTINATION ${CMAKE_BINARY_DIR})
