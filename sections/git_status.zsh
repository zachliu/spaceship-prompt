#
# Git status
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_GIT_STATUS_SHOW="${SPACESHIP_GIT_STATUS_SHOW=true}"
SPACESHIP_GIT_STATUS_PREFIX="${SPACESHIP_GIT_STATUS_PREFIX=" ["}"
SPACESHIP_GIT_STATUS_SUFFIX="${SPACESHIP_GIT_STATUS_SUFFIX="]"}"
SPACESHIP_GIT_STATUS_COLOR="${SPACESHIP_GIT_STATUS_COLOR="red"}"
SPACESHIP_GIT_STATUS_UNTRACKED="${SPACESHIP_GIT_STATUS_UNTRACKED="?"}"
SPACESHIP_GIT_STATUS_ADDED="${SPACESHIP_GIT_STATUS_ADDED="+"}"
SPACESHIP_GIT_STATUS_MODIFIED="${SPACESHIP_GIT_STATUS_MODIFIED="!"}"
SPACESHIP_GIT_STATUS_RENAMED="${SPACESHIP_GIT_STATUS_RENAMED="»"}"
SPACESHIP_GIT_STATUS_DELETED="${SPACESHIP_GIT_STATUS_DELETED="✘"}"
SPACESHIP_GIT_STATUS_STASHED="${SPACESHIP_GIT_STATUS_STASHED="$"}"
SPACESHIP_GIT_STATUS_UNMERGED="${SPACESHIP_GIT_STATUS_UNMERGED="="}"
SPACESHIP_GIT_STATUS_AHEAD="${SPACESHIP_GIT_STATUS_AHEAD="⇡"}"
SPACESHIP_GIT_STATUS_BEHIND="${SPACESHIP_GIT_STATUS_BEHIND="⇣"}"
SPACESHIP_GIT_STATUS_PULL="${SPACESHIP_GIT_STATUS_PULL="⇡"}"
SPACESHIP_GIT_STATUS_PUSH="${SPACESHIP_GIT_STATUS_PUSH="⇣"}"
SPACESHIP_GIT_STATUS_DIVERGED="${SPACESHIP_GIT_STATUS_DIVERGED="⇕"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# We used to depend on OMZ git library,
# But it doesn't handle many of the status indicator combinations.
# Also, It's hard to maintain external dependency.
# See PR #147 at https://git.io/vQkkB
# See git help status to know more about status formats
spaceship_git_status() {
  [[ $SPACESHIP_GIT_STATUS_SHOW == false ]] && return

  VCS_NO_LEAD_SPACE="$(echo -e "${vcs_info_msg_0_}" | sed -e 's/^[[:space:]]*//')"
  local git_current_branch="$VCS_NO_LEAD_SPACE"

  spaceship::is_git || return

  local INDEX git_status=""

  INDEX=$(command git status --porcelain -b 2> /dev/null)

  # Check for untracked files
  if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    git_status="%F{red}$SPACESHIP_GIT_STATUS_UNTRACKED%f$git_status"
  fi

  # Check for staged files
  if \
    $(echo "$INDEX" | command grep '^A[ MDAU] ' &> /dev/null) ||
    $(echo "$INDEX" | command grep '^M[ MD] ' &> /dev/null) ||
    $(echo "$INDEX" | command grep '^UA' &> /dev/null); then
    git_status="%F{yellow}$SPACESHIP_GIT_STATUS_ADDED%f$git_status"
  fi

  # Check for modified files
  if $(echo "$INDEX" | command grep '^[ MARC]M ' &> /dev/null); then
    git_status="%F{red}$SPACESHIP_GIT_STATUS_MODIFIED%f$git_status"
  fi

  # Check for renamed files
  if $(echo "$INDEX" | command grep '^R[ MD] ' &> /dev/null); then
    git_status="%F{yellow}$SPACESHIP_GIT_STATUS_RENAMED%f$git_status"
  fi

  # Check for deleted files
  if \
    $(echo "$INDEX" | command grep '^[MARCDU ]D ' &> /dev/null) ||
    $(echo "$INDEX" | command grep '^D[ UM] ' &> /dev/null); then
    git_status="%F{208}$SPACESHIP_GIT_STATUS_DELETED%f$git_status"
  fi

  # Check for stashes
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    local -a stashes
    stashes=$(command git stash list 2>/dev/null | wc -l)
    git_status="$git_status%F{red}($SPACESHIP_GIT_STATUS_STASHED${stashes})"
  fi

  # Check for unmerged files
  if \
    $(echo "$INDEX" | command grep '^U[UDA] ' &> /dev/null) ||
    $(echo "$INDEX" | command grep '^AA ' &> /dev/null) ||
    $(echo "$INDEX" | command grep '^DD ' &> /dev/null) ||
    $(echo "$INDEX" | command grep '^[DA]U ' &> /dev/null); then
    git_status="$git_status%F{red}$SPACESHIP_GIT_STATUS_UNMERGED%f"
  fi

  # Check whether branch is ahead
  local is_ahead=false
  local unpushed_commit=$(command git log --branches --not --remotes --decorate 2>/dev/null)
  if \
    $(echo "$INDEX" | command grep '^## [^ ]\+ .*ahead' &> /dev/null) ||
    $(echo "$unpushed_commit" | command grep ${git_current_branch} &> /dev/null); then
    is_ahead=true
  fi

  # Check whether branch is behind
  local is_behind=false
  if $(echo "$INDEX" | command grep '^## [^ ]\+ .*behind' &> /dev/null); then
    is_behind=true
  fi

  # Check wheather branch has diverged
  if [[ "$is_ahead" == true && "$is_behind" == true ]]; then
    git_status="$SPACESHIP_GIT_STATUS_DIVERGED$git_status"
  else
    [[ "$is_ahead" == true ]] && git_status="%F{yellow}$SPACESHIP_GIT_STATUS_PUSH%f$git_status"
    [[ "$is_behind" == true ]] && git_status="%F{yellow}$SPACESHIP_GIT_STATUS_PULL%f$git_status"
    # do nothing
  fi

  # Show remote ref name and number of commits ahead-of or behind
  local ahead behind remote
  local -a gitstatus

  # Are we ahead or behind a remote-tracking branch?
  # One way to avoid having to explicitly do --set-upstream is to use the
  # shorthand flag -u along with the very first git push as follows:
  # $ git push -u origin local-branch
  remote=$(command git rev-parse --verify ${git_current_branch}@{upstream} \
    --symbolic-full-name 2>/dev/null)

  if [[ -n ${remote} ]]; then
    ahead=$(command git rev-list ${git_current_branch}@{upstream}..HEAD 2>/dev/null | wc -l)
    (( $ahead )) && gitstatus+=( "($SPACESHIP_GIT_STATUS_AHEAD+${ahead})" )

    behind=$(command git rev-list HEAD..${git_current_branch}@{upstream} 2>/dev/null | wc -l)
    (( $behind )) && gitstatus+=( "($SPACESHIP_GIT_STATUS_BEHIND-${behind})" )

    git_status="$git_status%F{172}${(j:/:)gitstatus}"
  fi

  if [[ -n $git_status ]]; then
    # Status prefixes are colorized
    spaceship::section \
      "$SPACESHIP_GIT_STATUS_COLOR" \
      "$SPACESHIP_GIT_STATUS_PREFIX$git_status$SPACESHIP_GIT_STATUS_SUFFIX"
  fi
}
