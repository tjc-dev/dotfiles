# Version managers

# mise (universal version manager)
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
fi

# fnm (Fast Node Manager)
if command -v fnm &>/dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
