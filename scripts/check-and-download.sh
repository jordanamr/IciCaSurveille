#!/bin/bash

set -e

RELEASE=$1

if [ -z "$RELEASE" ]; then
    echo "Usage: $0 <release>"
    echo "Example: $0 main"
    exit 1
fi

echo "Checking version for release: $RELEASE"

# Get the current version
VERSION=$(cytrus-v6 version --game retro --release $RELEASE)

if [ -z "$VERSION" ]; then
    echo "Failed to get version for release $RELEASE"
    exit 1
fi

echo "Current version: $VERSION"

# Define the directory path
DIR_PATH="retro-${RELEASE}/${VERSION}"

# Check if this version already exists
if [ -d "$DIR_PATH" ]; then
    echo "Version $VERSION for release $RELEASE already exists. Skipping."
    exit 0
fi

echo "New version detected! Downloading version $VERSION for release $RELEASE..."

# Create the directory
mkdir -p "$DIR_PATH"

# Download the game files
cytrus-v6 download \
    --game retro \
    --release $RELEASE \
    --output "$DIR_PATH" \
    --platform=windows \
    --select **/retroclient/*.swf \
    --select **/retroclient/*.xml \
    --select **/retroclient/modules/*.swf \
    --select **/retroclient/preloader.swf \
    --select **/retroclient/js/* \
    --select **/app/*.js \
    --select **/app/*.jsc

echo "Successfully downloaded version $VERSION for release $RELEASE to $DIR_PATH"

# Create a version info file
cat > "$DIR_PATH/version-info.json" << EOF
{
  "version": "$VERSION",
  "release": "$RELEASE",
  "downloadedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "platform": "windows"
}
EOF

echo "Created version info file"