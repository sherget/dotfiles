#!/bin/bash
##################################
## Simple dotfiles setup script ##
##################################

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +"%Y%m%d_%H%M%S")"
mkdir -p "${BACKUP_DIR}"

# Dotfiles source -> destination go here
declare -A DOTFILE_MAP=(
    ["${DOTFILES_DIR}/bashrc"]="${HOME}/.bashrc"
    ["${DOTFILES_DIR}/X11/xinitrc"]="${HOME}/.xinitrc"
    ["${DOTFILES_DIR}/X11/Xresources"]="${HOME}/.Xresources"
    ["${DOTFILES_DIR}/config/zsh"]="${HOME}/.config/zsh"
    ["${DOTFILES_DIR}/config/alacritty"]="${HOME}/.config/alacritty"
    ["${DOTFILES_DIR}/config/tmux"]="${HOME}/.config/tmux"
    ["${DOTFILES_DIR}/config/xmonad"]="${HOME}/.config/xmonad"
    ["${DOTFILES_DIR}/config/nvim"]="${HOME}/.config/nvim"
    ["${DOTFILES_DIR}/config/phpactor"]="${HOME}/.config/phpactor"
    ["${DOTFILES_DIR}/config/opencode/opencode.json"]="${HOME}/.config/opencode/opencode.json"
    ["${DOTFILES_DIR}/gitconfig"]="${HOME}/.gitconfig"
)

setup_dotfiles() {
    for source in "${!DOTFILE_MAP[@]}"; do
        dest="${DOTFILE_MAP[${source}]}"
        
        if [ -L "${dest}" ] && [ "$(readlink "${dest}")" = "${source}" ]; then
            echo "Symlink already exists for ${dest}, skipping"
            continue
        fi
        
        if [ -e "${dest}" ] && [ ! -L "${dest}" ]; then
            echo "Backing up ${dest} to ${BACKUP_DIR}"
            mv "${dest}" "${BACKUP_DIR}/"
        fi
        
        echo "Creating symlink: ${source} -> ${dest}"
        ln -s "${source}" "${dest}"
    done
}

main() {
    echo "Setting up dotfiles..."
    setup_dotfiles
    echo "Done. Backup stored in ${BACKUP_DIR}"
    mv /home/$(whoami)/.oh-my-zsh /home/$(whoami)/.config/zsh/.oh-my-zsh
    xmonad --recompile
}

main
