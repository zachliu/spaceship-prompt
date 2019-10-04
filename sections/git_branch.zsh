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

  local git_current_branch="$vcs_info_msg_0_"
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

  local current_git_status="$(git status 2> /dev/null)"
  local current_branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
  local current_git_commit="$(git --no-pager diff --stat origin/${current_branch} 2>/dev/null)"
  if [[ $current_git_status == "" ]]; then
    SPACESHIP_GIT_BRANCH_COLOR="cyan"
  elif [[ ! $current_git_status =~ "working tree clean" ]]; then
    # do nothing
  elif [[ $current_git_status =~ "Your branch is ahead of 'origin/$current_branch'" ]] || \
    [[ -n $current_git_commit ]]; then
    SPACESHIP_GIT_BRANCH_COLOR="yellow"
  elif [[ $current_git_status =~ "nothing to commit" ]] && \
    [[ ! -n $current_git_commit ]]; then
    # do nothing
  else
    # do nothing
  fi

  git_current_branch="${git_current_branch#heads/}"
  git_current_branch="${git_current_branch/.../}"

  spaceship::section \
    "$SPACESHIP_GIT_BRANCH_COLOR" \
    "$SPACESHIP_GIT_BRANCH_PREFIX${git_current_branch}$SPACESHIP_GIT_BRANCH_SUFFIX"
}
