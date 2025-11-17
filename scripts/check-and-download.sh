#!/bin/bash

set -e

GAME=$1
RELEASE=$2

if [ -z "$GAME" ] || [ -z "$RELEASE" ]; then
    echo "Usage: $0 <game> <release>"
    echo "Example: $0 retro main"
    echo "Example: $0 wakfu main"
    exit 1
fi

echo "Checking version for game: $GAME, release: $RELEASE"

# Get the current version
VERSION=$(cytrus-v6 version --game $GAME --release $RELEASE)

if [ -z "$VERSION" ]; then
    echo "Failed to get version for release $RELEASE"
    exit 1
fi

echo "Current version: $VERSION"

# Define the directory path
DIR_PATH="${GAME}-${RELEASE}/${VERSION}"

# Check if this version already exists
if [ -d "$DIR_PATH" ]; then
    echo "Version $VERSION for release $RELEASE already exists. Skipping."
    exit 0
fi

echo "New version detected! Downloading version $VERSION for release $RELEASE..."

# Create the directory
mkdir -p "$DIR_PATH"

# Download the game files
if [ "$GAME" = "retro" ]; then
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
elif [ "$GAME" = "wakfu" ]; then
    cytrus-v6 download \
        --game wakfu \
        --release $RELEASE \
        --output "$DIR_PATH" \
        --platform=windows \
        --select **/wakfu-client.jar
else
    echo "Unknown game: $GAME"
    exit 1
fi

echo "Successfully downloaded version $VERSION for release $RELEASE to $DIR_PATH"

# Create a version info file
cat > "$DIR_PATH/version-info.json" << EOF
{
  "game": "$GAME",
  "version": "$VERSION",
  "release": "$RELEASE",
  "downloadedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "platform": "windows"
}
EOF

echo "Created version info file"