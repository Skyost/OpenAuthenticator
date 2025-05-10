#!/bin/bash

set -e

POLICY_ID="polkit.app.openauthenticator"
POLICY_FILENAME="${POLICY_ID}.policy"
POLICY_SRC_PATH="$(dirname "$0")/meta/polkit/${POLICY_FILENAME}"
POLICY_DEST_PATH="/usr/share/polkit-1/actions/${POLICY_FILENAME}"

LOCALES=("fr" "de" "it" "pt")
PO_DIR="$(dirname "$0")/meta/polkit/po"

# Check root
if [[ $EUID -ne 0 ]]; then
  echo "⚠️  This script must be run as root (sudo)."
  exit 1
fi

# Check if the policy file exists
if [[ ! -f "$POLICY_SRC_PATH" ]]; then
  echo "❌ Policy file not found at: $POLICY_SRC_PATH"
  exit 1
fi

# Install the policy file
echo "📄 Installing policy file..."
cp "$POLICY_SRC_PATH" "$POLICY_DEST_PATH"
chmod 644 "$POLICY_DEST_PATH"

# Compile and install translations
echo "🌐 Installing translations..."
for LOCALE in "${LOCALES[@]}"; do
  PO_FILE="$PO_DIR/${LOCALE}.po"
  MO_DIR="/usr/share/locale/${LOCALE}/LC_MESSAGES"
  MO_FILE="${MO_DIR}/${POLICY_ID}.mo"

  if [[ ! -f "$PO_FILE" ]]; then
    echo "⚠️  Skipping missing $PO_FILE"
    continue
  fi

  echo "🛠️  Compiling $PO_FILE..."
  mkdir -p "$MO_DIR"
  msgfmt "$PO_FILE" -o "$MO_FILE"
done

# Restart polkit to apply changes
echo "🔄 Restarting polkit..."
systemctl restart polkit

echo "✅ Policy file and translations installed successfully."
