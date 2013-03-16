# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Programmable completion for some Chromium OS build scripts.

_list_repo_commands() {
  local repo=${COMP_WORDS[0]}
  "${repo}" help --all | grep -E '^  ' | sed 's/  \([^ ]\+\) .\+/\1/'
}

_list_repo_branches() {
  local repo=${COMP_WORDS[0]}
  "${repo}" branches 2>&1 | grep \| | sed 's/[ *][Pp ] *\([^ ]\+\) .*/\1/'
}

_list_repo_projects() {
  local repo=${COMP_WORDS[0]}
  local manifest=$(mktemp)
  "${repo}" manifest -o "${manifest}" >& /dev/null
  grep 'project name=' "${manifest}" | sed 's/.\+name="\([^"]\+\)".\+/\1/'
  rm -f "${manifest}" >& /dev/null
}

# Complete the repo <command> argument.
_complete_repo_command() {
  [ ${COMP_CWORD} -eq 1 ] || return 1
  local command=${COMP_WORDS[1]}
  COMPREPLY=($(compgen -W "$(_list_repo_commands)" -- "${command}"))
  return 0
}

_complete_repo_arg() {
  [ ${COMP_CWORD} -gt 1 ] || return 1
  local command=${COMP_WORDS[1]}
  local current=${COMP_WORDS[COMP_CWORD]}
  if [[ ${command} == "abandon" ]]; then
    if [[ ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "$(_list_repo_branches)" -- "${current}"))
    else
      COMPREPLY=($(compgen -W "$(_list_repo_projects)" -- "${current}"))
    fi
    return 0
  fi
  if [[ ${command} == "help" ]]; then
    [ ${COMP_CWORD} -eq 2 ] && \
      COMPREPLY=($(compgen -W "$(_list_repo_commands)" -- "${current}"))
    return 0
  fi
  if [[ ${command} == "start" ]]; then
    [ ${COMP_CWORD} -gt 2 ] && \
      COMPREPLY=($(compgen -W "$(_list_repo_projects)" -- "${current}"))
    return 0
  fi
  return 1
}

# Complete the repo arguments.
_complete_repo() {
  COMPREPLY=()
  _complete_repo_command && return 0
  _complete_repo_arg && return 0
  return 0
}

complete -F _complete_repo repo

# Add a way to get the "m" branch from repo easily; used by __git_branch_ps1()
#
# Repo seems to maintain a phony 'm/' remote and it always seems to be the name
# of the manifest branch.  This will retrieve it.
__git_m_branch() {
  local git_dir=$(git rev-parse --git-dir 2> /dev/null)
  if [ -n "${git_dir}" ]; then
    echo $(cd ${git_dir}/refs/remotes/m 2> /dev/null && ls)
  fi
}

# A "subclass" of __git_ps1 that adds the manifest branch name into the prompt.
# ...if you're on manifest branch "0.11.257.B" and local branch "lo" and
# pass " (%s)", we'll output " (0.11.257.B/lo)".  Note that we'll never show
# the manifest branch 'master', since it's so common.
__git_branch_ps1() {
  local format_str="${1:- (%s)}"
  local m_branch=$(__git_m_branch)
  if [ "${m_branch}" != "master" -a -n "${m_branch}" ]; then
    format_str=$(printf "${format_str}" "${m_branch}/%s")
  fi
  # for subshells, prefix the prompt with the shell nesting level
  local lshlvl=""
  [ ! -z "${SHLVL##*[!0-9]*}" ] && [ ${SHLVL} -gt 1 ] && lshlvl="${SHLVL} "
  __git_ps1 "${lshlvl}${format_str}"
}

# Prompt functions should not error when in subshells
export -f __gitdir
export -f __git_ps1
export -f __git_m_branch
export -f __git_branch_ps1
