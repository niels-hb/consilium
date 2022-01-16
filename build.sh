#!/bin/sh
set -e;

BUILD_NAME=$1;
BUILD_NUMBER=$2;

if [ -z $BUILD_NAME ] || [ -z $BUILD_NUMBER ]; then
    echo "Missing parameters. Run with: ./build.sh <build name> <build number>";
    exit 1;
fi

echo "Building version ${BUILD_NAME} (${BUILD_NUMBER}).\n";

echo "⌛ Building AAB...";
flutter build appbundle --release --build-number="${BUILD_NUMBER}" --build-name="${BUILD_NAME}";
echo "✅ Built AAB";

echo "⌛ Building IPA...";
flutter build ipa --release --build-number="${BUILD_NUMBER}" --build-name="${BUILD_NAME}";
echo "✅ Built IPA";
