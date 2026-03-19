#!/bin/bash
set -e

echo "========================================="
echo "Starting Flutter Web Build..."
echo "========================================="

# Flutterのインストール先
FLUTTER_HOME=$HOME/.flutter
FLUTTER_BIN=$FLUTTER_HOME/bin/flutter

# Flutterが既にインストールされているか確認
if [ -d "$FLUTTER_HOME" ]; then
  echo "✓ Flutter already exists, updating..."
  cd $FLUTTER_HOME && git pull && cd -
else
  echo "⬇ Cloning Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $FLUTTER_HOME
fi

echo "========================================="
echo "Configuring Flutter..."
echo "========================================="

# Flutterの設定
$FLUTTER_BIN config --enable-web --no-analytics
$FLUTTER_BIN --version

echo "========================================="
echo "Getting dependencies..."
echo "========================================="
$FLUTTER_BIN pub get

echo "========================================="
echo "Building web (this may take 5-10 minutes)..."
echo "========================================="
$FLUTTER_BIN build web --release

echo "========================================="
echo "Build completed!"
echo "Output directory contents:"
ls -la build/web/
echo "========================================="
