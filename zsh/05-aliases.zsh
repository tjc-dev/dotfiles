# Shell aliases

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/projects"

# Git shorthand
alias g="git"

# ls (prefer eza if available, fall back to ls)
if command -v eza &>/dev/null; then
    alias l="eza -lF --git"
    alias la="eza -laF --git"
    alias lsd="eza -lDF"
    alias ls="eza"
else
    alias l="ls -lFG"
    alias la="ls -lAFG"
    alias lsd="ls -lFG | grep --color=never '^d'"
    alias ls="command ls -G"
fi

# Colored grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Sudo aliases
alias sudo='sudo '

# Networking
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# macOS shortcuts
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias c="tr -d '\n' | pbcopy"

# Update everything
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup'

# Reload shell
alias reload="exec ${SHELL} -l"
alias path='echo -e ${PATH//:/\\n}'

# Use bat instead of cat if available
if command -v bat &>/dev/null; then
    alias cat="bat --paging=never"
fi

# Ghostty configuration
alias gconfig="\$HOME/.config/ghostty/gconfig"
alias ghostty-warp="\$HOME/.config/ghostty/interactive-config.sh"
alias gconfig-interactive="\$HOME/.config/ghostty/interactive-config.sh"
alias gconfig-switch="\$HOME/.config/ghostty/switch-config.sh"
alias gcyber="\$HOME/.config/ghostty/gconfig cyber"
alias gminimal="\$HOME/.config/ghostty/gconfig minimal"
alias gcozy="\$HOME/.config/ghostty/gconfig cozy"
alias gpro="\$HOME/.config/ghostty/gconfig pro"

# Workflow snippets (pet)
if command -v pet &>/dev/null; then
    alias pw='pet search'
    alias pe='pet exec'
    alias pn='pet new'
    alias pl='pet list'
fi
