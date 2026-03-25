#!/usr/bin/env bash
# ==============================================
# Module: Homebrew packages
# ==============================================

REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
    log_change "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    log_skip "Homebrew already installed"
fi

# Update Homebrew
log "  Updating Homebrew..."
brew update --quiet

# Install packages from Brewfile - brew bundle is already idempotent
log "  Installing packages from Brewfile (skips already-installed)..."
BUNDLE_OUTPUT=$(brew bundle --file="$REPO_DIR/Brewfile" 2>&1) || true

# Parse output for new installs
while IFS= read -r line; do
    if [[ "$line" == *"Installing"* ]] || [[ "$line" == *"Upgrading"* ]]; then
        log_change "$line"
    fi
done <<< "$BUNDLE_OUTPUT"

# Check if everything succeeded
if brew bundle check --file="$REPO_DIR/Brewfile" &>/dev/null; then
    log_skip "All Brewfile packages satisfied"
else
    log "  WARNING: Some Brewfile packages may not have installed correctly"
fi

# Create GNU coreutils symlink if missing
BREW_PREFIX=$(brew --prefix)
if [[ -f "${BREW_PREFIX}/bin/gsha256sum" ]] && [[ ! -f "${BREW_PREFIX}/bin/sha256sum" ]]; then
    ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"
    log_change "Created sha256sum symlink"
else
    log_skip "sha256sum symlink"
fi

# Setup fzf key bindings if not already done
if command -v fzf &>/dev/null; then
    FZF_INSTALL="${BREW_PREFIX}/opt/fzf/install"
    if [[ -f "$FZF_INSTALL" ]] && [[ ! -f ~/.fzf.zsh ]] && [[ ! -f ~/.fzf.bash ]]; then
        "$FZF_INSTALL" --key-bindings --completion --no-update-rc --no-bash --no-fish
        log_change "Configured fzf key bindings"
    else
        log_skip "fzf key bindings already configured"
    fi
fi
