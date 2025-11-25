#!/usr/bin/env bash
#
# reset_chrome_managed_state.sh
# Clears macOS-level "browser managed by your organization" state for Google Chrome
# without deleting Chrome profiles, bookmarks, or history.
#

set -euo pipefail

echo "==> This script will:"
echo "    - Stop Google Chrome"
echo "    - Remove Google auto-update (Keystone) residues"
echo "    - Clear Google/Chrome preference plists for this user"
echo "    - Clear some Chrome enterprise/management caches"
echo "    - Reset app quarantine attributes for Google Chrome"
echo
echo "    It does NOT delete your Chrome profiles or bookmarks."
echo
read -r -p "Continue? [y/N]: " ans
case "${ans:-n}" in
  y|Y) echo "Proceeding...";;
  *) echo "Aborting."; exit 1;;
esac

CURRENT_USER="$(whoami)"

echo "==> Killing Google Chrome if running..."
killall "Google Chrome" 2>/dev/null || true

echo "==> Removing system-wide Google Keystone / updater components (sudo required)..."
sudo rm -rf /Library/Google/GoogleSoftwareUpdate 2>/dev/null || true
sudo rm -rf /Library/Google/GoogleUpdater 2>/dev/null || true
sudo rm -rf /Library/LaunchAgents/com.google.keystone.* 2>/dev/null || true
sudo rm -rf /Library/LaunchDaemons/com.google.keystone.* 2>/dev/null || true

echo "==> Removing user-level Google updater components..."
rm -rf "$HOME/Library/Google/GoogleSoftwareUpdate" 2>/dev/null || true
rm -rf "$HOME/Library/Google/GoogleUpdater" 2>/dev/null || true

echo "==> Removing Google/Chrome preference plists for user '$CURRENT_USER'..."
rm -f "$HOME/Library/Preferences/com.google.Chrome.plist" 2>/dev/null || true
rm -f "$HOME/Library/Preferences/com.google.ChromeUpdater.plist" 2>/dev/null || true
rm -f "$HOME/Library/Preferences/com.google.GoogleUpdater.plist" 2>/dev/null || true
rm -f "$HOME/Library/Preferences/com.google.Keystone.Agent.plist" 2>/dev/null || true
rm -f "$HOME/Library/Preferences/com.google.SoftwareUpdate.plist" 2>/dev/null || true

echo "==> Flushing macOS preference cache (cfprefsd)..."
killall cfprefsd 2>/dev/null || true

CHROME_SUPPORT_DIR="$HOME/Library/Application Support/Google/Chrome"

if [ -d "$CHROME_SUPPORT_DIR" ]; then
  echo "==> Clearing Chrome enterprise/management-related caches in:"
  echo "    $CHROME_SUPPORT_DIR"
  rm -rf "$CHROME_SUPPORT_DIR/Enterprise" 2>/dev/null || true
  rm -rf "$CHROME_SUPPORT_DIR/"*Management* 2>/dev/null || true
  rm -rf "$CHROME_SUPPORT_DIR/Policy" 2>/dev/null || true
  rm -rf "$CHROME_SUPPORT_DIR/System Profile" 2>/dev/null || true
  rm -rf "$CHROME_SUPPORT_DIR/CertificateRevocation" 2>/dev/null || true
else
  echo "==> Chrome support directory not found at:"
  echo "    $CHROME_SUPPORT_DIR"
fi

CHROME_APP="/Applications/Google Chrome.app"
if [ -d "$CHROME_APP" ]; then
  echo "==> Clearing extended attributes (quarantine, etc.) on Chrome app bundle..."
  xattr -rc "$CHROME_APP" 2>/dev/null || true
else
  echo "==> Chrome app not found at $CHROME_APP (skipping xattr reset)."
fi

echo
echo "==> Done with cleanup."
echo "==> To fully apply changes, you should REBOOT macOS before reopening Chrome."
echo
echo "After reboot, check:"
echo "  chrome://management"
echo "  chrome://policy"
echo
echo "You should see 'Chrome is not managed by your organization' for non-UMBC profiles."
