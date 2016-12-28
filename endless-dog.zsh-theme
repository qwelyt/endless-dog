# vim:ft=zsh ts=2 sw=2 sts=2
#
# Theme name: endless-dog
# Author:     qwelyt
#
# This theme uses much of the same setup as "agnoster" in regards to structure.
# The design is heavily taken from the "grml-zsh-config" https://grml.org/zsh/
#

prompt_segment(){
  local fg bg bold
  bg="%K{default}"
  [[ -n $1 ]] && fg="%F{$1}" || fg="%f"
  [[ -n $2 ]] && bold="$2" || bold=false
  
  echo -n "%{$bg%}%{$fg%}"

  if [ "$bold" = true ]; then
    echo -n "%B"
  else
  fi

  [[ -n "${3}" ]] && echo -n "${3}"

  if [ "$bold" = true ]; then
    echo -n "%b"
  fi
}

prompt_status(){
  [[ $RETVAL -ne 0 ]] && prompt_segment red true "$RETVAL "
}

prompt_context(){
    if [[ $UID -eq 0 ]]; then
      prompt_segment red true "%n"
      prompt_segment default false "@%m"
    else
      prompt_segment blue true "%n"
      prompt_segment default false "@%m"
    fi
}

prompt_dir(){
  prompt_segment default true " %~"
}

prompt_vcs_type(){
    prompt_segment magenta false " ("
    prompt_segment default false "$1"
    prompt_segment magenta false ")"
}

prompt_vcs_branch(){
  # $1 == dirty-flag
  # $2 == Branch
  prompt_segment magenta false "["
  if [[ "$1" = true ]]; then
    prompt_segment yellow false "$2"
  else
    prompt_segment green false "$2"
  fi
  prompt_segment magenta false "]"

}

prompt_git(){
  (( $+commands[git] )) || return
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    local dirty branch
    prompt_vcs_type "git"

    dirty=$(parse_git_dirty)
    branch=$(git_current_branch)

    if [[ -n $dirty ]]; then
      prompt_vcs_branch true "$branch"
    else
      prompt_vcs_branch false "$branch"
    fi

  fi
}

prompt_svn() {
  if [[ -n $(in_svn) ]]; then
    local rev branch display
    prompt_vcs_type "svn"

    rev=$(svn_get_rev_nr)
    branch=$(svn_get_branch_name)
    display="${rev}:${branch}"
    if [[ $(svn_dirty_choose_pwd 1 0) -eq 1 ]]; then
      prompt_vcs_branch true "$display"
    else
      prompt_vcs_branch false "$display"
    fi
  fi
}

prompt_userchar(){
  prompt_segment default false " %#"
}

prompt_end(){
  echo -n "%{%f%}"
}
build_prompt() {
    RETVAL=$?
    prompt_status
    prompt_context
    prompt_dir
    prompt_git
    prompt_svn
    prompt_userchar
    prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '

