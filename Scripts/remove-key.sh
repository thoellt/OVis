#!/bin/sh

# Delete the keychain
security delete-keychain macos-build.keychain

# Delete the provisioning profile
rm -f "~/Library/MobileDevice/Provisioning Profiles/ceda4023-2dff-4e7b-8795-394866ea9589.provisionprofile"