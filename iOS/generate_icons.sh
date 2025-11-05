#!/bin/bash

# Script to generate all required iOS app icon sizes from 1024x1024 source
# Usage: ./generate_icons.sh

set -e

SOURCE_ICON="HomeDesignAI/Resources/Assets.xcassets/AppIcon.appiconset/logo-1024.png"
OUTPUT_DIR="HomeDesignAI/Resources/Assets.xcassets/AppIcon.appiconset"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "❌ Error: Source icon not found at $SOURCE_ICON"
    exit 1
fi

echo "🎨 Generating iOS app icons from $SOURCE_ICON..."
echo ""

# iPhone app icons
echo "📱 Generating iPhone icons..."
sips -z 180 180 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-180.png" > /dev/null
sips -z 120 120 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-120.png" > /dev/null

# iPhone Spotlight icons
echo "🔍 Generating iPhone Spotlight icons..."
sips -z 80 80 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-80.png" > /dev/null

# iPhone Settings icons
echo "⚙️  Generating iPhone Settings icons..."
sips -z 87 87 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-87.png" > /dev/null
sips -z 58 58 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-58.png" > /dev/null

# iPad app icons
echo "📱 Generating iPad icons..."
sips -z 167 167 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-167.png" > /dev/null
sips -z 152 152 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-152.png" > /dev/null
sips -z 76 76 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-76.png" > /dev/null

# iPad Settings icons
echo "⚙️  Generating iPad Settings icons..."
sips -z 29 29 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-29.png" > /dev/null

# Notification icons
echo "🔔 Generating Notification icons..."
sips -z 40 40 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-40.png" > /dev/null
sips -z 60 60 "$SOURCE_ICON" --out "$OUTPUT_DIR/icon-60.png" > /dev/null

echo ""
echo "✅ All icons generated successfully!"
echo ""
echo "Generated icons:"
ls -lh "$OUTPUT_DIR"/*.png | awk '{print "  " $9 " (" $5 ")"}'
echo ""
echo "📝 Next step: Update Contents.json in Xcode to reference these icons"
