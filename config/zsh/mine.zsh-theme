PROMPT="%(?:%B%F{255}%1{ထ%}%{$reset_color%} :%B%F{246}%}%1{လ%}%{$reset_color%} ) %{%F{33}%}%c% %{$reset_color%} %F{255}%"
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[white]%}[%{%B%F{255}%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%F{255}% "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[white]%}][%B%F{124}%}%1{✗%}%{$reset_color%}] "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[white]%}][%B%F{34}%}%1{✓%}%{$reset_color%}] "
