#!/bin/bash
set -e

echo "Installing Flutter..."

# Flutterのインストール先
FLUTTER_HOME=/vercel/.local/share/flutter
FLUTTER_BIN=$FLUTTER_HOME/bin/flutter

# Flutterが既にインストールされているか確認
if [ -d "$FLUTTER_HOME" ]; then
  echo "Flutter already exists, updating..."
  cd $FLUTTER_HOME && git pull && cd -
else
  echo "Cloning Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $FLUTTER_HOME
fi

# Flutterの設定
$FLUTTER_BIN config --enable-web
$FLUTTER_BIN doctor

echo "Getting dependencies..."
$FLUTTER_BIN pub get

echo "Building web..."
$FLUTTER_BIN build web --release --web-renderer canvaskit

echo "Build completed!"
