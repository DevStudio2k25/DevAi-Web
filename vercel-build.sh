#!/bin/bash

# Download Flutter SDK
git clone https://github.com/flutter/flutter.git --depth 1 -b stable /opt/flutter
export PATH=$PATH:/opt/flutter/bin

# Install Flutter
flutter precache
flutter doctor -v

# Enable web
flutter config --enable-web

# Get packages
flutter pub get

# Build
flutter build web --release 