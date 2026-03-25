#!/usr/bin/env bash
# ==============================================
# Module: Ghostty terminal configuration
# ==============================================

REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
GHOSTTY_SRC="$REPO_DIR/ghostty"
GHOSTTY_DEST="$HOME/.config/ghostty"

mkdir -p "$GHOSTTY_DEST"

# Sync function: copy file only if different
sync_file() {
    local src="$1"
    local dest="$2"
    local relative="${src#$GHOSTTY_SRC/}"

    mkdir -p "$(dirname "$dest")"

    if [[ -f "$dest" ]] && diff -q "$src" "$dest" &>/dev/null; then
        log_skip "ghostty/$relative unchanged"
        return
    fi

    cp "$src" "$dest"
    log_change "ghostty/$relative updated"
}

# Sync all ghostty config files
while IFS= read -r -d '' file; do
    relative="${file#$GHOSTTY_SRC/}"
    sync_file "$file" "$GHOSTTY_DEST/$relative"
done < <(find "$GHOSTTY_SRC" -type f -not -name '.DS_Store' -print0)

# Make scripts executable
for script in "$GHOSTTY_DEST"/*.sh "$GHOSTTY_DEST"/gconfig; do
    if [[ -f "$script" ]] && [[ ! -x "$script" ]]; then
        chmod +x "$script"
        log_change "Made $(basename "$script") executable"
    fi
done
