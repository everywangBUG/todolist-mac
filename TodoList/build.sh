#!/bin/bash

set -e

echo "=========================================="
echo "  TodoList macOS 构建脚本"
echo "=========================================="

PROJECT_DIR="/Users/gene/Desktop/web/todolist-mac/TodoList"
BUILD_OUTPUT="/Users/gene/Desktop/web/todolist-mac"

echo ""
echo "步骤 1: 清理旧构建..."
cd "$PROJECT_DIR"
rm -rf .build/arm64-apple-macosx/release/TodoList
sudo rm -rf "$BUILD_OUTPUT/TodoList.app"
sudo rm -f "$BUILD_OUTPUT/TodoList.pkg"

echo ""
echo "步骤 2: 编译项目 (Release 配置)..."
swift build -c release

echo ""
echo "步骤 3: 创建应用包结构..."
mkdir -p "$BUILD_OUTPUT/TodoList.app/Contents/MacOS"
mkdir -p "$BUILD_OUTPUT/TodoList.app/Contents/Resources"

echo ""
echo "步骤 4: 复制可执行文件..."
cp "$PROJECT_DIR/.build/arm64-apple-macosx/release/TodoList" "$BUILD_OUTPUT/TodoList.app/Contents/MacOS/"

echo ""
echo "步骤 5: 复制资源文件..."
cp -r "$PROJECT_DIR/TodoList/Resources/"* "$BUILD_OUTPUT/TodoList.app/Contents/Resources/"

echo ""
echo "步骤 6: 创建 Info.plist..."
cat > "$BUILD_OUTPUT/TodoList.app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>TodoList</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.TodoList</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>TodoList</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo ""
echo "步骤 7: 设置可执行权限..."
chmod +x "$BUILD_OUTPUT/TodoList.app/Contents/MacOS/TodoList"

echo ""
echo "步骤 8: 创建安装包..."
pkgbuild \
  --component "$BUILD_OUTPUT/TodoList.app" \
  --install-location /Applications \
  --identifier com.example.TodoList \
  --version 1.0 \
  "$BUILD_OUTPUT/TodoList.pkg"

echo ""
echo "=========================================="
echo "  构建完成!"
echo "=========================================="
echo ""
echo "生成的文件:"
echo "  - 应用包: $BUILD_OUTPUT/TodoList.app"
echo "  - 安装包: $BUILD_OUTPUT/TodoList.pkg"
echo ""
echo "使用方法:"
echo "  1. 双击 TodoList.pkg 安装"
echo "  2. 或直接运行: open $BUILD_OUTPUT/TodoList.app"
echo ""
