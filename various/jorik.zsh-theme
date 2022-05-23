ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}\uE0A0 "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[magenta]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%{$fg_bold[green]%}%~%{$reset_color%}$(git_prompt_info)
%(?:%{$fg_bold[white]%}➜ :%{$fg[red]%}➜ )%{$reset_color%} '
