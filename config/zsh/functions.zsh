custom-find() {
    BUFFER='find ~ -name "" 2> /dev/null'
    CURSOR=14
}
zle -N custom-find
