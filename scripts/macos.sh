#!/usr/bin/env bash
# ==============================================
# Module: macOS system defaults
# ==============================================

REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MACOS_SCRIPT="$REPO_DIR/macos/defaults.sh"

if [[ ! -f "$MACOS_SCRIPT" ]]; then
    log "  WARNING: macos/defaults.sh not found, skipping"
    return 0 2>/dev/null || exit 0
fi

# Track if any defaults actually changed by comparing a snapshot
DEFAULTS_BEFORE=$(defaults read 2>/dev/null | md5)

log "  Applying macOS system defaults..."
bash "$MACOS_SCRIPT" 2>/dev/null

DEFAULTS_AFTER=$(defaults read 2>/dev/null | md5)

if [[ "$DEFAULTS_BEFORE" != "$DEFAULTS_AFTER" ]]; then
    log_change "macOS system defaults updated (restart apps or log out to apply)"
else
    log_skip "macOS defaults already set"
fi
