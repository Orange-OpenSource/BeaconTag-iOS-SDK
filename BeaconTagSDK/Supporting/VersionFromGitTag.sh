#!/bin/sh

# Get previous version from Git.
MARKETING_VERSION=$(git describe --abbrev=0 --tags)

# Increment version if we have a previous one.
if [ -n "$MARKETING_VERSION" ]; then
    COMPONENTS=(`echo $MARKETING_VERSION | tr '.' ' '`)
    let INCREMENT=${COMPONENTS[2]}+1
    MARKETING_VERSION=${COMPONENTS[0]}'.'${COMPONENTS[1]}'.'${INCREMENT}
# Very first version.
else
    MARKETING_VERSION="1.1.1"
fi

# Save new version to the AppInfo.plist
/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString ${MARKETING_VERSION}" "${INFOPLIST_FILE}"

# Set new version in OrangeBeacon.h
OLD_VERSION_DEFINE="^#define BEACON_TAG_SDK_VERSION @\"*[0-9]\.*[0-9]\.[0-9]\""
NEW_VERSION_DEFINE="#define BEACON_TAG_SDK_VERSION @\"${MARKETING_VERSION}\""

sed -i '' -e "s/${OLD_VERSION_DEFINE}/${NEW_VERSION_DEFINE}/" "${SRCROOT}/BeaconTagSDK/BeaconTagSDK.h"
