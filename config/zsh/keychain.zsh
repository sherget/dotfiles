if ! [[ -n "$SSH_AUTH_SOCK" && -S "$SSH_AUTH_SOCK" && -d "$HOME/.keychain" ]]; then
  eval "$(keychain --quiet --eval ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_work)"
  [[ -n $SSH_AUTH_SOCK ]] && export SSH_AUTH_SOCK
  [[ -n $GPG_AGENT_INFO ]] && export GPG_AGENT_INFO
fi
