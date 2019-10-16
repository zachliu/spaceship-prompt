#
# Git branch
#
# Show current git branch

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_GIT_BRANCH_SHOW="${SPACESHIP_GIT_BRANCH_SHOW=true}"
SPACESHIP_GIT_BRANCH_PREFIX="${SPACESHIP_GIT_BRANCH_PREFIX="$SPACESHIP_GIT_SYMBOL"}"
SPACESHIP_GIT_BRANCH_SUFFIX="${SPACESHIP_GIT_BRANCH_SUFFIX=""}"
SPACESHIP_GIT_BRANCH_COLOR="${SPACESHIP_GIT_BRANCH_COLOR="green"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

spaceship_git_branch() {
  [[ $SPACESHIP_GIT_BRANCH_SHOW == false ]] && return

  VCS_NO_LEAD_SPACE="$(echo -e "${vcs_info_msg_0_}" | sed -e 's/^[[:space:]]*//')"
  local git_current_branch="$VCS_NO_LEAD_SPACE"
  [[ -z "$git_current_branch" ]] && return

  spaceship::is_git || return

  INDEX=$(command git status --porcelain -b 2> /dev/null)

  # Check for untracked files
  if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    SPACESHIP_GIT_BRANCH_COLOR="red"
  fi

  # Check for modified files
  if $(echo "$INDEX" | command grep '^[ MARC]M ' &> /dev/null); then
    SPACESHIP_GIT_BRANCH_COLOR="red"
  fi

  # Check for renamed files
  if $(echo "$INDEX" | command grep '^R[ MD] ' &> /dev/null); then
    SPACESHIP_GIT_BRANCH_COLOR="red"
  fi

  # Check for deleted files
  if $(echo "$INDEX" | command grep '^[MARCDU ]D ' &> /dev/null); then
    SPACESHIP_GIT_BRANCH_COLOR="red"
  elif $(echo "$INDEX" | command grep '^D[ UM] ' &> /dev/null); then
    SPACESHIP_GIT_BRANCH_COLOR="red"
  fi

  # Check for unmerged files
  if $(echo "$INDEX" | command grep '^U[UDA] ' &> /dev/null); then
    SPACESHIP_GIT_BRANCH_COLOR="red"
  elif $(echo "$INDEX" | command grep '^AA ' &> /dev/null); then
    SPACESHIP_GIT_BRANCH_COLOR="red"
  elif $(echo "$INDEX" | command grep '^DD ' &> /dev/null); then
    SPACESHIP_GIT_BRANCH_COLOR="red"
  elif $(echo "$INDEX" | command grep '^[DA]U ' &> /dev/null); then
    SPACESHIP_GIT_BRANCH_COLOR="red"
  fi

  # Colors for the branch name
  local git_current_status="$(git status 2> /dev/null)"
  local git_current_commit="$(git --no-pager diff --stat origin/${git_current_branch} 2>/dev/null)"
  if [[ $git_current_status == "" ]]; then
    # SPACESHIP_GIT_BRANCH_COLOR="cyan"
  elif [[ ! $git_current_status =~ "working tree clean" ]]; then
    # do nothing
  elif [[ $git_current_status =~ "Your branch is ahead of 'origin/$git_current_branch'" ]] || \
    [[ -n $git_current_commit ]]; then
    SPACESHIP_GIT_BRANCH_COLOR="yellow"
  else
    # do nothing
  fi

  git_current_branch="${git_current_branch#heads/}"
  git_current_branch="${git_current_branch/.../}"

  spaceship::section \
    "$SPACESHIP_GIT_BRANCH_COLOR" \
    "$SPACESHIP_GIT_BRANCH_PREFIX${git_current_branch}$SPACESHIP_GIT_BRANCH_SUFFIX"
}
