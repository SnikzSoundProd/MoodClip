#!/bin/bash
set -e

cd "$(dirname "$0")"

PROJECT_DIR="/c/Users/apex/Downloads/New folder/MoodClip"
COMPILE_DIR="/c/Users/apex/Downloads/New folder/MoodClip/compile"
SRC_DIR="/c/Users/apex/Downloads/New folder/MoodClip/src"

echo "=== Cleaning compile directory ==="
rm -rf "$COMPILE_DIR"
mkdir -p "$COMPILE_DIR"
cd "$COMPILE_DIR"

echo "=== Setting up environment ==="
export PATH="/ucrt64/share/qt6/bin:/ucrt64/bin:$PATH"
export QT_PLUGIN_PATH="/ucrt64/share/qt6/plugins"

echo "=== Copying QML files ==="
mkdir -p qml/components qml/dialogs
cp "$SRC_DIR"/qml/*.qml qml/
cp "$SRC_DIR"/qml/components/*.qml qml/components/
cp "$SRC_DIR"/qml/dialogs/*.qml qml/dialogs/
cp "$SRC_DIR"/qml/qmldir qml/

echo "=== Generating MOC files ==="
moc "$SRC_DIR"/core/ProjectManager.h -o moc_ProjectManager.cpp
moc "$SRC_DIR"/core/Clip.h -o moc_Clip.cpp
moc "$SRC_DIR"/core/StoryboardModel.h -o moc_StoryboardModel.cpp
moc "$SRC_DIR"/core/StoryboardFrame.h -o moc_StoryboardFrame.cpp
moc "$SRC_DIR"/core/AssetLibrary.h -o moc_AssetLibrary.cpp
moc "$SRC_DIR"/core/AssetItem.h -o moc_AssetItem.cpp
moc "$SRC_DIR"/core/ExportManager.h -o moc_ExportManager.cpp

echo "=== Compiling ==="

INCLUDES=(
    -I"$SRC_DIR"
    -I/ucrt64/include/qt6
    -I/ucrt64/include/qt6/QtCore
    -I/ucrt64/include/qt6/QtGui
    -I/ucrt64/include/qt6/QtQuick
    -I/ucrt64/include/qt6/QtQuickControls2
    -I/ucrt64/include/qt6/QtSql
    -I/ucrt64/include/qt6/QtQml
    -I/ucrt64/include/qt6/QtNetwork
    -I/ucrt64/include/qt6/QtOpenGL
    -I/ucrt64/include/qt6/QtWidgets
    -I.
    -fPIC
)

SOURCES=(
    "$SRC_DIR/main.cpp"
    "$SRC_DIR/core/ProjectManager.cpp"
    "$SRC_DIR/core/Clip.cpp"
    "$SRC_DIR/core/StoryboardModel.cpp"
    "$SRC_DIR/core/StoryboardFrame.cpp"
    "$SRC_DIR/core/AssetLibrary.cpp"
    "$SRC_DIR/core/AssetItem.cpp"
    "$SRC_DIR/core/ExportManager.cpp"
    moc_ProjectManager.cpp
    moc_Clip.cpp
    moc_StoryboardModel.cpp
    moc_StoryboardFrame.cpp
    moc_AssetLibrary.cpp
    moc_AssetItem.cpp
    moc_ExportManager.cpp
)

for file in "${SOURCES[@]}"; do
    echo "  -> $(basename "$file")"
    g++ -std=c++20 -c "$file" "${INCLUDES[@]}"
done

echo "=== Linking ==="
g++ -o MoodClip.exe *.o -L/ucrt64/lib -lQt6Core -lQt6Gui -lQt6Quick -lQt6QuickControls2 -lQt6Sql -lQt6QmlModels -lQt6Qml -lQt6Network -lQt6OpenGL -lQt6Widgets -lpthread

echo "=== Build complete ==="
echo "Run with:"
echo "  cd \"$COMPILE_DIR\""
echo "  export QT_PLUGIN_PATH=/ucrt64/share/qt6/plugins"
echo "  ./MoodClip.exe"
