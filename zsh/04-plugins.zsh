# Shell plugins and enhancements

BREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# zsh-autosuggestions
if [[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    export ZSH_AUTOSUGGEST_USE_ASYNC=1
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"
    export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# zsh-syntax-highlighting (must load AFTER autosuggestions)
if [[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# fzf
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
    export FZF_DEFAULT_OPTS="
      --height 40%
      --layout=reverse
      --border
      --preview-window=right:50%
      --bind='ctrl-/:toggle-preview'
    "
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi

# zoxide (smart cd)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# atuin (shell history)
if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh)"
fi

# starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# thefuck (command corrections)
if command -v thefuck &>/dev/null; then
    eval $(thefuck --alias 2>/dev/null)
    eval $(thefuck --alias fix 2>/dev/null)
fi

# zsh-completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# Docker completions
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
