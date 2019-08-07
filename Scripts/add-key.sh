#!/bin/sh

# Decrypt provisioning profile and certificates
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/profile/ceda4023-2dff-4e7b-8795-394866ea9589.provisionprofile.enc -d -a -out scripts/profile/ceda4023-2dff-4e7b-8795-394866ea9589.provisionprofile
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dist.cer.enc -d -a -out scripts/certs/dist.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in scripts/certs/dist.p12.enc -d -a -out scripts/certs/dist.p12

# Create a keychain
security create-keychain -p $KEYCHAIN_PASSWORD macos-build.keychain

# Make the keychain default, so xcodebuild will use it for signing
security default-keychain -s macos-build.keychain

# Unlock the keychain
security unlock-keychain -p $KEYCHAIN_PASSWORD macos-build.keychain

# Set keychain timeout to 1 hour for long builds
# see http://www.egeek.me/2013/02/23/jenkins-and-xcode-user-interaction-is-not-allowed/
security set-keychain-settings -t 3600 -l ~/Library/Keychains/macos-build.keychain

# Add certificates to keychain and allow codesign to access them
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/macos-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/dist.cer -k ~/Library/Keychains/macos-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/dist.p12 -k ~/Library/Keychains/macos-build.keychain -P $KEY_PASSWORD -T /usr/bin/codesign

# https://docs.travis-ci.com/user/common-build-problems/#mac-macos-sierra-1012-code-signing-errors
security set-key-partition-list -S apple-tool:,apple: -s -k $KEYCHAIN_PASSWORD macos-build.keychain

# Put the provisioning profile in place
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp "./scripts/profile/ceda4023-2dff-4e7b-8795-394866ea9589.provisionprofile" ~/Library/MobileDevice/Provisioning\ Profiles/