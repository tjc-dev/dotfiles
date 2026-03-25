#!/usr/bin/env bash
# ==============================================
# Module: Dotfiles (symlink to home directory)
# ==============================================

REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DOTFILES_DIR="$REPO_DIR/dotfiles-home"

# Symlink a file: create_link <source> <target>
create_link() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        local current_target
        current_target=$(readlink "$dest")
        if [[ "$current_target" == "$src" ]]; then
            log_skip "$(basename "$dest") already linked"
            return
        fi
    fi

    # Backup existing file if it's a real file (not a symlink)
    if [[ -e "$dest" ]] && [[ ! -L "$dest" ]]; then
        local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$dest" "$backup"
        log_change "Backed up $(basename "$dest") -> $backup"
    fi

    ln -sf "$src" "$dest"
    log_change "Linked $(basename "$dest") -> $src"
}

# Simple dotfiles (files in dotfiles-home/ -> ~/.<name>)
SIMPLE_FILES=(
    .aliases
    .bash_profile
    .bash_prompt
    .bashrc
    .curlrc
    .editorconfig
    .exports
    .functions
    .gitconfig
    .hushlogin
    .inputrc
    .vimrc
    .wgetrc
)

for file in "${SIMPLE_FILES[@]}"; do
    if [[ -e "$DOTFILES_DIR/$file" ]]; then
        create_link "$DOTFILES_DIR/$file" "$HOME/$file"
    fi
done

# .vim directory - symlink the whole directory
if [[ -d "$DOTFILES_DIR/.vim" ]]; then
    create_link "$DOTFILES_DIR/.vim" "$HOME/.vim"
fi

# .gitignore (global) - special name to avoid confusion with repo .gitignore
if [[ -e "$DOTFILES_DIR/.gitignore_global" ]]; then
    create_link "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore"
fi

# .editorconfig
if [[ -e "$DOTFILES_DIR/.editorconfig" ]]; then
    create_link "$DOTFILES_DIR/.editorconfig" "$HOME/.editorconfig"
fi
