
# ──────────────────────────────
# Auto-start
# ──────────────────────────────
fastfetch
echo ''

# ──────────────────────────────
# P10K Instant Prompt
# ──────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ──────────────────────────────
# Shell integrations
# ──────────────────────────────
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# ──────────────────────────────
# Binds 
# ──────────────────────────────
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
bindkey "^k" kill-line
bindkey "^J" history-search-forward
bindkey "^K" history-search-backward
bindkey "^R" fzf-history-widget

# ──────────────────────────────
# Set window titles
# ──────────────────────────────
precmd() {
    print -Pn "\e]0;%n@%m:%~\a"
}

# ──────────────────────────────
# Zinit (Plugin Manager)
# ──────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# ──────────────────────────────
# Snippets (Zinit)
# ──────────────────────────────
zinit snippet OMZP::git

# Load sudo, but use 'atload' to modify its bindings *after* it loads
zinit ice atload"
    # UNBIND the default EscEsc from the sudo plugin
    # We use '\e\e' as that's what the plugin itself uses
    bindkey -r -M emacs '\e\e'
    bindkey -r -M vicmd '\e\e'
    bindkey -r -M viins '\e\e'

    # BIND the sudo command to Ctrl-N
    bindkey -M emacs '^N' sudo-command-line
    bindkey -M vicmd '^N' sudo-command-line
    bindkey -M viins '^N' sudo-command-line
"
zinit snippet OMZP::sudo

zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

# ──────────────────────────────
# Plugins (Zinit)
# ──────────────────────────────
zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

# ──────────────────────────────
# Autoload
# ──────────────────────────────
autoload -Uz compinit && compinit

# ──────────────────────────────
# P10K configuration
# ──────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ──────────────────────────────
# Global Gitignore setup
# ──────────────────────────────
GITIGNORE_GLOBAL="$HOME/.gitignore_global"

if [[ ! -f "$GITIGNORE_GLOBAL" ]]; then
  touch "$GITIGNORE_GLOBAL"
fi

if [[ "$(git config --global core.excludesfile)" != "$GITIGNORE_GLOBAL" ]]; then
  git config --global core.excludesfile "$GITIGNORE_GLOBAL"
fi

if ! grep -qx ".DS_Store" "$GITIGNORE_GLOBAL"; then
  echo ".DS_Store" >> "$GITIGNORE_GLOBAL"
fi

# ──────────────────────────────
# Aliases
# ──────────────────────────────
alias bat='bat --color=always --theme=base16 --style=plain'
alias c=clear
alias cd=z
alias fzf="command fzf --preview '
if [ -d {} ]; then
eza -l --color=always {} || ls -la {}
else
bat --color=always --theme=base16 --style=plain {}
fi
'"
alias ff=fastfetch
alias flatpak='flatpak --user'
alias grep=rg
alias k=kill
alias lf=~/.config/lf/lfrun
alias paru='paru --skipreview'
alias pk=pkill
alias swaybar='waybar -c ~/.config/waybar/sway/config.jsonc'
alias spot=spotify_player
alias hyprbar='waybar -c ~/.config/waybar/hyprland/config.jsonc'
alias vim=nvim
alias yz=yazi

alias wb='west build'
alias wbf='west build && west flash'

function serial {
  local port
  port=$(ls /dev/cu.* 2>/dev/null | fzf)
  [[ -n "$port" ]] && tio "$port"
}

alias dplayout="$HOME/dplayout/display-layout-manager.sh"

# ──────────────────────────────
# Package aliases
# ──────────────────────────────
alias pkg-add='sudo pacman -S'
alias pkg-search='pacman -Ss'
alias pkg-rm='sudo pacman -Rns'
alias pkg-sync='sudo pacman -Syu'
alias pkg-grep='pacman -Q'
alias pkg-info='pacman -Qi'
alias pkg-list='pacman -Q'
alias pkg-orphan='pacman -Qdt'
alias pkg-clean='sudo pacman -Rns $(pacman -Qdtq)'
alias pkg-files='pacman -Ql'
alias pkg-own='pacman -Qo'
# AUR
alias aur-add='paru --skipreview --aur -S'
alias aur-search='paru --skipreview --aur -Ss'
alias aur-sync='paru -Sua'

# ──────────────────────────────
# History
# ──────────────────────────────
HISTSIZE=5000
HISTFILE=~/.zhistory
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space


# Binds for word-wise navigation with Option/Alt key
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word
# Alternative common sequences
bindkey "\eb" backward-word
bindkey "\ef" forward-word

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load local-only, private configuration
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
