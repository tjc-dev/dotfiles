# PATH additions

# Homebrew (Apple Silicon)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# GNU coreutils
if [[ -d "$(brew --prefix 2>/dev/null)/opt/coreutils/libexec/gnubin" ]]; then
    export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
fi

# Home bin
export PATH="$HOME/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# uv / Python tools
export PATH="$HOME/.local/bin:$PATH"
