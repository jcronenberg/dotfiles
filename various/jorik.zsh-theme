ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}\uE0A0 "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[magenta]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%{$fg_bold[green]%}%~%{$reset_color%}$(git_prompt_info)
%(?:%{$fg_bold[white]%}➜ :%{$fg[red]%}➜ )%{$reset_color%} '
function _user_host() {
  local me
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USERNAME ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "$me"
  fi
}
RPROMPT="%{$(echotc UP 1)%}${FG[237]}$(_user_host)%{$reset_color%}%{$(echotc DO 1)%"
