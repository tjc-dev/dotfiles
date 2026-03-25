#!/usr/bin/env bash
set -euo pipefail

# ==============================================
# macOS Setup - Unified Bootstrapper
# ==============================================
# Idempotent setup script that combines dotfiles,
# Homebrew packages, macOS defaults, Ghostty terminal,
# zsh enhancements, and tmux configuration.
#
# Usage:
#   ./setup.sh              # Interactive (prompts before each module)
#   ./setup.sh --all        # Run everything non-interactively
#   ./setup.sh --module     # Run a specific module (e.g. --brew, --dotfiles)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d_%H%M%S).log"
CHANGE_COUNT=0

# --- Logging helpers ---

log() {
    local msg="$1"
    echo "$msg" | tee -a "$LOG_FILE"
}

log_change() {
    local msg="$1"
    CHANGE_COUNT=$((CHANGE_COUNT + 1))
    echo "  [CHANGED] $msg" | tee -a "$LOG_FILE"
}

log_skip() {
    local msg="$1"
    echo "  [OK]      $msg" >> "$LOG_FILE"
}

log_section() {
    local msg="$1"
    echo "" | tee -a "$LOG_FILE"
    echo "=== $msg ===" | tee -a "$LOG_FILE"
}

# Export helpers so module scripts can use them
export LOG_FILE CHANGE_COUNT
export -f log log_change log_skip log_section

# --- Module runner ---

run_module() {
    local name="$1"
    local script="$SCRIPT_DIR/scripts/$name.sh"
    if [[ ! -f "$script" ]]; then
        log "ERROR: Module script not found: $script"
        return 1
    fi
    log_section "$name"
    bash "$script" "$SCRIPT_DIR"
}

should_run() {
    local module="$1"
    if [[ "$RUN_ALL" == "true" ]]; then
        return 0
    fi
    if [[ -n "${RUN_MODULE:-}" ]]; then
        [[ "$RUN_MODULE" == "$module" ]]
        return $?
    fi
    read -p "Run $module setup? (y/n) " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]]
}

# --- Parse arguments ---

RUN_ALL="false"
RUN_MODULE=""

for arg in "$@"; do
    case "$arg" in
        --all)       RUN_ALL="true" ;;
        --brew)      RUN_MODULE="brew" ;;
        --dotfiles)  RUN_MODULE="dotfiles" ;;
        --macos)     RUN_MODULE="macos" ;;
        --ghostty)   RUN_MODULE="ghostty" ;;
        --zsh)       RUN_MODULE="zsh" ;;
        --help|-h)
            echo "Usage: ./setup.sh [--all] [--brew|--dotfiles|--macos|--ghostty|--zsh]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

# --- Main ---

log "macOS Setup - $(date)"
log "Log file: $LOG_FILE"
echo ""

MODULES=(brew dotfiles macos ghostty zsh)

for module in "${MODULES[@]}"; do
    if should_run "$module"; then
        # Source the module so CHANGE_COUNT increments carry over
        log_section "$module"
        source "$SCRIPT_DIR/scripts/$module.sh" "$SCRIPT_DIR"
    fi
done

# --- Summary ---

echo ""
echo "=============================="
if [[ $CHANGE_COUNT -eq 0 ]]; then
    log "Setup complete. Everything was already up to date."
else
    log "Setup complete. $CHANGE_COUNT change(s) made."
fi
log "Full log: $LOG_FILE"
echo "=============================="
