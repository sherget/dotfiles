export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$HOME/.pyenv/bin:$PATH
export PATH="$HOME/.bun/bin:$PATH"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export ZDOTDIR=${HOME}/.config/zsh
export OHMYZSH_PATH=$HOME/.config/zsh/.oh-my-zsh
export ZSH=$OHMYZSH_PATH
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
export EDITOR=nvim
export VISUAL=$EDITOR
export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git --exclude ".wine"'
export FZF_TMUX_OPTS="-p"
export LANG=en_US.UTF-8

HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS  

plugins=(git z)
source $OHMYZSH_PATH/oh-my-zsh.sh
source $ZDOTDIR/mine.zsh-theme

if [[ -n "$SSH_CONNECTION" ]] || [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
	export EDITOR='vim'
else
	export EDITOR='nvim'
fi

if [ "$TMUX" = "" ]; then
	tmux a -dt main -c 'tmux source ~/.config/tmux/tmux.conf' ||
		tmux new -s main -c 'tmux source ~/.config/tmux/tmux.conf';
fi

# Aliases
source $ZDOTDIR/aliases.zsh
# Keymaps
source $ZDOTDIR/keymaps.zsh

# OS dependent imports
if [[ $(grep -oP '^ID=\K\w+' /etc/os-release) == "ubuntu" ]]; then
	source $ZDOTDIR/ubuntu/aliases.ubuntu.zsh
	source $ZDOTDIR/ubuntu/keymaps.ubuntu.zsh
	source /usr/share/doc/fzf/examples/completion.zsh
	source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [[ $(grep -oP '^ID=\K\w+' /etc/os-release) == "arch" ]]; then
	source $ZDOTDIR/archlinux/aliases.archlinux.zsh
	source $ZDOTDIR/archlinux/keymaps.archlinux.zsh
	source /usr/share/fzf/completion.zsh
	source /usr/share/fzf/key-bindings.zsh
fi

source $ZDOTDIR/keychain.zsh

# opencode
export PATH=/home/shin/.opencode/bin:$PATH
