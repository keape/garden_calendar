#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="GardenCalendar"
SCHEME="GardenCalendar"

echo "=== Garden Calendar - Build Script ==="

# Check for xcodebuild
if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: xcodebuild not found."
    echo "Install Xcode command line tools: xcode-select --install"
    exit 1
fi

# Get available destinations
echo ""
echo "Available destinations:"
xcodebuild -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -showdestinations 2>/dev/null | grep -E "iOS|Simulator" | head -20

echo ""
echo "Select build type:"
echo "  1) Simulator (iPhone 15)"
echo "  2) Simulator (iPhone SE)"
echo "  3) Connected device"
echo "  4) Generic iOS device (archive)"
read -p "Choice [1-4]: " choice

case $choice in
    1)
        DEST="platform=iOS Simulator,name=iPhone 15"
        echo "Building for iPhone 15 Simulator..."
        ;;
    2)
        DEST="platform=iOS Simulator,name=iPhone SE (3rd generation)"
        echo "Building for iPhone SE Simulator..."
        ;;
    3)
        echo "Looking for connected devices..."
        UDID=$(system_profiler SPUSBDataType 2>/dev/null | grep -A 10 "iPhone" | grep "Serial Number" | head -1 | awk -F': ' '{print $2}' | tr -d ' ')
        if [ -z "$UDID" ]; then
            echo "No connected device found. Using generic."
            DEST="generic/platform=iOS"
        else
            DEST="id=$UDID"
            echo "Found device: $UDID"
        fi
        ;;
    4)
        DEST="generic/platform=iOS"
        echo "Building for generic iOS device..."
        ;;
    *)
        DEST="platform=iOS Simulator,name=iPhone 15"
        echo "Defaulting to iPhone 15 Simulator..."
        ;;
esac

echo ""
echo "Building..."
xcodebuild -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "$DEST" \
    -configuration Debug \
    clean build

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Build successful! ==="
    
    if [[ "$choice" == "3" ]] && [ -n "$UDID" ]; then
        echo "Installing to device..."
        xcodebuild -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
            -scheme "$SCHEME" \
            -destination "id=$UDID" \
            -configuration Debug \
            build run
    elif [[ "$choice" == "1" || "$choice" == "2" ]]; then
        echo ""
        echo "To launch in simulator:"
        echo "  xcrun simctl boot \"$DEST\""
        echo "  xcrun simctl install booted <path-to-app>"
        echo "  xcrun simctl launch booted com.gardencalendar.app"
    fi
else
    echo ""
    echo "=== Build failed ==="
    exit 1
fi
