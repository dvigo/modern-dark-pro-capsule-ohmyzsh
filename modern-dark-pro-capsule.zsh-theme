# ------------------------------------------------------------------------------
# Modern Dark Pro - Capsule Oh My Zsh Theme
# A fork of Modern Dark Pro featuring capsule/pill-shaped status segments.
# Inspired by modern developer terminal aesthetics.
# Repository: https://github.com/dvigo/modern-dark-pro-ohmyzsh
# ------------------------------------------------------------------------------

# Color Palette Configurator
# Detects truecolor support and falls back to standard 256-color codes if not supported.
if [[ "${COLORTERM}" == "truecolor" || "${COLORTERM}" == "24bit" ]]; then
  # TrueColor 24-bit Hex Colors
  if [[ "${MODERN_DARK_PRO_VARIANT}" == "monokai" ]]; then
    COLOR_CONNECTOR="#75715e"   # Gray
    COLOR_PATH="#66d9ef"        # Blue
    COLOR_GIT_BRANCH="#a6e22e"  # Green/Sage to match capsule aesthetic
    COLOR_SUCCESS="#a6e22e"     # Green
    COLOR_WARNING="#e6db74"     # Yellow
    COLOR_ERROR="#f92672"       # Red
    COLOR_EXEC_TIME="#ae81ff"   # Purple
    COLOR_TEXT="#f8f8f2"        # Foreground
  else
    COLOR_CONNECTOR="#555555"   # Border/Connector Gray
    COLOR_PATH="#64b5f6"        # Blue
    COLOR_GIT_BRANCH="#81c784"  # Sage green matching the screenshot
    COLOR_SUCCESS="#81c784"     # Green
    COLOR_WARNING="#ffb74d"     # Orange/Yellow
    COLOR_ERROR="#e57373"       # Red
    COLOR_EXEC_TIME="#ba68c8"   # Purple
    COLOR_TEXT="#e0e0e0"        # Foreground
  fi
else
  # Fallback to standard 256-color codes (widely supported on all terminals)
  if [[ "${MODERN_DARK_PRO_VARIANT}" == "monokai" ]]; then
    COLOR_CONNECTOR="101"
    COLOR_PATH="81"
    COLOR_GIT_BRANCH="148"
    COLOR_SUCCESS="148"
    COLOR_WARNING="185"
    COLOR_ERROR="197"
    COLOR_EXEC_TIME="141"
    COLOR_TEXT="255"
  else
    COLOR_CONNECTOR="240"
    COLOR_PATH="75"
    COLOR_GIT_BRANCH="114"
    COLOR_SUCCESS="114"
    COLOR_WARNING="215"
    COLOR_ERROR="167"
    COLOR_EXEC_TIME="176"
    COLOR_TEXT="254"
  fi
fi

# Configuration Variables with defaults
MODERN_DARK_PRO_CHAR="${MODERN_DARK_PRO_CHAR:-❯}"
MODERN_DARK_PRO_SHOW_EXEC_TIME="${MODERN_DARK_PRO_SHOW_EXEC_TIME:-true}"
MODERN_DARK_PRO_EXEC_TIME_MIN="${MODERN_DARK_PRO_EXEC_TIME_MIN:-2}"
MODERN_DARK_PRO_NERD_FONTS="${MODERN_DARK_PRO_NERD_FONTS:-true}" # Default to true for capsule theme
MODERN_DARK_PRO_PATH_STYLE="${MODERN_DARK_PRO_PATH_STYLE:-limit}"
MODERN_DARK_PRO_PATH_DEPTH="${MODERN_DARK_PRO_PATH_DEPTH:-3}"
MODERN_DARK_PRO_PILL_STYLE="${MODERN_DARK_PRO_PILL_STYLE:-bracket}" # bracket, round, or none
MODERN_DARK_PRO_PILL_COLOR_STYLE="${MODERN_DARK_PRO_PILL_COLOR_STYLE:-solid}" # solid or dark (applies to round style)
MODERN_DARK_PRO_PROMPT_LAYOUT="${MODERN_DARK_PRO_PROMPT_LAYOUT:-two-line}" # single, two-line, or classic
MODERN_DARK_PRO_SHOW_CLOCK="${MODERN_DARK_PRO_SHOW_CLOCK:-true}"
MODERN_DARK_PRO_BORDER_COLOR="${MODERN_DARK_PRO_BORDER_COLOR:-${COLOR_CONNECTOR}}"

# Enable terminal colors for BSD ls (macOS) and GNU ls (Linux)
export CLICOLOR=1
if [[ "${MODERN_DARK_PRO_VARIANT}" == "monokai" ]]; then
  export LSCOLORS="exfxcxdxbxegedabagacad"  # Monokai BSD colors
  export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=32:bd=34:cd=34:ow=36" # Monokai GNU colors
else
  export LSCOLORS="exfxcxdxbxegedabagacad"  # Night BSD colors
  export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=32:bd=34:cd=34:ow=34" # Night GNU colors
fi

# Autocomplete list-colors configuration matching the theme
zmodload zsh/complist 2>/dev/null
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Symbol configurations based on Nerd Fonts toggle
if [[ "${MODERN_DARK_PRO_NERD_FONTS}" == "true" ]]; then
  # Developer / Nerd Fonts Icons
  MODERN_DARK_PRO_DIR_SYMBOL="${MODERN_DARK_PRO_DIR_SYMBOL:-}"         # Folder outline
  MODERN_DARK_PRO_GIT_SYMBOL="${MODERN_DARK_PRO_GIT_SYMBOL:-}"         # Git Branch icon
  MODERN_DARK_PRO_CHANGES_SYMBOL="${MODERN_DARK_PRO_CHANGES_SYMBOL:-}" # File/Doc icon
  MODERN_DARK_PRO_TIME_SYMBOL="${MODERN_DARK_PRO_TIME_SYMBOL:-}"       # Clock
  MODERN_DARK_PRO_AHEAD_SYMBOL="${MODERN_DARK_PRO_AHEAD_SYMBOL:-}"
  MODERN_DARK_PRO_BEHIND_SYMBOL="${MODERN_DARK_PRO_BEHIND_SYMBOL:-}"
  MODERN_DARK_PRO_LOCK_SYMBOL="${MODERN_DARK_PRO_LOCK_SYMBOL:-}"       # Lock
  MODERN_DARK_PRO_SSH_SYMBOL="${MODERN_DARK_PRO_SSH_SYMBOL:-}"         # Server/SSH
  MODERN_DARK_PRO_JOBS_SYMBOL="${MODERN_DARK_PRO_JOBS_SYMBOL:-}"        # Gear
  MODERN_DARK_PRO_PYTHON_SYMBOL="${MODERN_DARK_PRO_PYTHON_SYMBOL:-}"   # Python
  MODERN_DARK_PRO_NODE_SYMBOL="${MODERN_DARK_PRO_NODE_SYMBOL:-}"        # Node.js
  MODERN_DARK_PRO_GO_SYMBOL="${MODERN_DARK_PRO_GO_SYMBOL:-}"          # Go
  MODERN_DARK_PRO_RUST_SYMBOL="${MODERN_DARK_PRO_RUST_SYMBOL:-}"        # Rust
  MODERN_DARK_PRO_TF_SYMBOL="${MODERN_DARK_PRO_TF_SYMBOL:-󱁢}"          # Terraform
  MODERN_DARK_PRO_K8S_SYMBOL="${MODERN_DARK_PRO_K8S_SYMBOL:-☸}"        # Kubernetes
  MODERN_DARK_PRO_AWS_SYMBOL="${MODERN_DARK_PRO_AWS_SYMBOL:-}"        # AWS
else
  # Standard Unicode Fallback
  MODERN_DARK_PRO_DIR_SYMBOL="${MODERN_DARK_PRO_DIR_SYMBOL:-📁}"
  MODERN_DARK_PRO_GIT_SYMBOL="${MODERN_DARK_PRO_GIT_SYMBOL:-⌥}"
  MODERN_DARK_PRO_CHANGES_SYMBOL="${MODERN_DARK_PRO_CHANGES_SYMBOL:-📄}"
  MODERN_DARK_PRO_TIME_SYMBOL="${MODERN_DARK_PRO_TIME_SYMBOL:-🕒}"
  MODERN_DARK_PRO_AHEAD_SYMBOL="${MODERN_DARK_PRO_AHEAD_SYMBOL:-⇡}"
  MODERN_DARK_PRO_BEHIND_SYMBOL="${MODERN_DARK_PRO_BEHIND_SYMBOL:-⇣}"
  MODERN_DARK_PRO_LOCK_SYMBOL="${MODERN_DARK_PRO_LOCK_SYMBOL:-🔒}"
  MODERN_DARK_PRO_SSH_SYMBOL="${MODERN_DARK_PRO_SSH_SYMBOL:-ssh}"
  MODERN_DARK_PRO_JOBS_SYMBOL="${MODERN_DARK_PRO_JOBS_SYMBOL:-⚙}"
  MODERN_DARK_PRO_PYTHON_SYMBOL="${MODERN_DARK_PRO_PYTHON_SYMBOL:-py}"
  MODERN_DARK_PRO_NODE_SYMBOL="${MODERN_DARK_PRO_NODE_SYMBOL:-node}"
  MODERN_DARK_PRO_GO_SYMBOL="${MODERN_DARK_PRO_GO_SYMBOL:-go}"
  MODERN_DARK_PRO_RUST_SYMBOL="${MODERN_DARK_PRO_RUST_SYMBOL:-rust}"
  MODERN_DARK_PRO_TF_SYMBOL="${MODERN_DARK_PRO_TF_SYMBOL:-tf}"
  MODERN_DARK_PRO_K8S_SYMBOL="${MODERN_DARK_PRO_K8S_SYMBOL:-k8s}"
  MODERN_DARK_PRO_AWS_SYMBOL="${MODERN_DARK_PRO_AWS_SYMBOL:-aws}"
fi

# Renders a segment inside a capsule/pill
# Arguments:
#   $1: Foreground color of the content
#   $2: Icon/Symbol
#   $3: Text content
#   $4: Optional background color (for solid style)
function _modern_dark_pro_make_pill() {
  local fg="$1"
  local symbol="$2"
  local content="$3"
  local bg="${4:-}"
  
  if [[ -z "${content}" ]]; then
    return
  fi

  local style="${MODERN_DARK_PRO_PILL_STYLE:-bracket}"
  
  if [[ "${style}" == "round" ]]; then
    local color_style="${MODERN_DARK_PRO_PILL_COLOR_STYLE:-solid}"
    local pill_bg
    local pill_fg
    local final_content="${content}"
    
    if [[ "${color_style}" == "solid" ]]; then
      # Solid colored pill with dark text (like preview-capsule.png)
      pill_bg="${fg}"
      pill_fg="${MODERN_DARK_PRO_PILL_TEXT_COLOR:-#111111}"
      
      # Strip embedded colors so text is uniformly dark and readable
      setopt local_options extendedglob
      final_content="${content//\%F\{[^\}]##\}/}"
      final_content="${final_content//\%f/}"
    else
      # Dark gray pill with colored text
      pill_bg="${bg:-#282828}"
      pill_fg="${fg}"
    fi
    
    local inner=""
    if [[ -n "${symbol}" ]]; then
      inner="%F{${pill_fg}}${symbol} ${final_content}%f"
    else
      inner="%F{${pill_fg}}${final_content}%f"
    fi
    
    echo -n "%F{${pill_bg}}%K{${pill_bg}} ${inner} %k%F{${pill_bg}}%f"
  elif [[ "${style}" == "bracket" ]]; then
    # Bracket outline pill matching screenshot style
    local inner=""
    if [[ -n "${symbol}" ]]; then
      inner="%F{${fg}}${symbol} ${content}%f"
    else
      inner="%F{${fg}}${content}%f"
    fi
    echo -n "%F{${MODERN_DARK_PRO_BORDER_COLOR}}[ %f${inner} %F{${MODERN_DARK_PRO_BORDER_COLOR}}]%f"
  else
    # Simple text (no container)
    local inner=""
    if [[ -n "${symbol}" ]]; then
      inner="%F{${fg}}${symbol} ${content}%f"
    else
      inner="%F{${fg}}${content}%f"
    fi
    echo -n " ${inner}"
  fi
}

# Dynamic Git Status Caching Variables
_MODERN_DARK_PRO_GIT_BRANCH=""
_MODERN_DARK_PRO_GIT_AHEAD=0
_MODERN_DARK_PRO_GIT_BEHIND=0
_MODERN_DARK_PRO_GIT_FILES=0
_MODERN_DARK_PRO_GIT_INSERTIONS=0
_MODERN_DARK_PRO_GIT_DELETIONS=0
_MODERN_DARK_PRO_GIT_UNTRACKED=0

# Updates git cache in precmd to keep the prompt blazingly fast
function _modern_dark_pro_update_git() {
  # Avoid executing commands if not inside Git repository
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    _MODERN_DARK_PRO_GIT_BRANCH=""
    return
  fi

  # Get branch info
  local branch_line
  branch_line=$(git status --porcelain -b 2>/dev/null | head -n 1)
  
  local ref=""
  if [[ "${branch_line}" =~ '^## No commits yet on (.+)$' ]]; then
    ref="${match[1]}"
  elif [[ "${branch_line}" =~ '^## ([^. ]+)' ]]; then
    ref="${match[1]}"
  fi
  
  if [[ -z "${ref}" || "${ref}" == "HEAD" ]]; then
    ref=$(git rev-parse --short HEAD 2>/dev/null)
  fi
  _MODERN_DARK_PRO_GIT_BRANCH="${ref}"

  # Parse ahead/behind status
  _MODERN_DARK_PRO_GIT_AHEAD=0
  _MODERN_DARK_PRO_GIT_BEHIND=0
  if [[ "${branch_line}" =~ 'ahead ([0-9]+)' ]]; then
    _MODERN_DARK_PRO_GIT_AHEAD="${match[1]}"
  fi
  if [[ "${branch_line}" =~ 'behind ([0-9]+)' ]]; then
    _MODERN_DARK_PRO_GIT_BEHIND="${match[1]}"
  fi

  # Parse git diff shortstat
  _MODERN_DARK_PRO_GIT_FILES=0
  _MODERN_DARK_PRO_GIT_INSERTIONS=0
  _MODERN_DARK_PRO_GIT_DELETIONS=0
  
  local diff_stat
  diff_stat=$(git diff HEAD --shortstat 2>/dev/null)
  if [[ -n "${diff_stat}" ]]; then
    if [[ "${diff_stat}" =~ '([0-9]+) file' ]]; then
      _MODERN_DARK_PRO_GIT_FILES="${match[1]}"
    fi
    if [[ "${diff_stat}" =~ '([0-9]+) insertion' ]]; then
      _MODERN_DARK_PRO_GIT_INSERTIONS="${match[1]}"
    fi
    if [[ "${diff_stat}" =~ '([0-9]+) deletion' ]]; then
      _MODERN_DARK_PRO_GIT_DELETIONS="${match[1]}"
    fi
  fi

  # Count untracked files
  _MODERN_DARK_PRO_GIT_UNTRACKED=0
  local untracked_files
  untracked_files=$(git status --porcelain 2>/dev/null | grep '^??')
  if [[ -n "${untracked_files}" ]]; then
    _MODERN_DARK_PRO_GIT_UNTRACKED=$(echo "${untracked_files}" | wc -l | tr -d ' ')
  fi
}

# Individual Capsule Generators

function _modern_dark_pro_path_capsule() {
  local path_val="${_MODERN_DARK_PRO_PATH_VAL}"
  local lock=""
  if [[ ! -w . ]]; then
    lock=" %F{${COLOR_ERROR}}${MODERN_DARK_PRO_LOCK_SYMBOL}%f"
  fi
  
  _modern_dark_pro_make_pill "${COLOR_PATH}" "${MODERN_DARK_PRO_DIR_SYMBOL}" "${path_val}${lock}"
}

function _modern_dark_pro_git_branch_capsule() {
  if [[ -z "${_MODERN_DARK_PRO_GIT_BRANCH}" ]]; then
    return
  fi

  local branch_info="${_MODERN_DARK_PRO_GIT_BRANCH}"
  local ahead_str=""
  local behind_str=""
  
  if [[ ${_MODERN_DARK_PRO_GIT_AHEAD} -gt 0 ]]; then
    ahead_str=" ${MODERN_DARK_PRO_AHEAD_SYMBOL}${_MODERN_DARK_PRO_GIT_AHEAD}"
  fi
  if [[ ${_MODERN_DARK_PRO_GIT_BEHIND} -gt 0 ]]; then
    behind_str=" ${MODERN_DARK_PRO_BEHIND_SYMBOL}${_MODERN_DARK_PRO_GIT_BEHIND}"
  fi
  
  local content="${branch_info}${ahead_str}${behind_str}"
  _modern_dark_pro_make_pill "${COLOR_GIT_BRANCH}" "${MODERN_DARK_PRO_GIT_SYMBOL}" "${content}"
}

function _modern_dark_pro_git_changes_capsule() {
  if [[ -z "${_MODERN_DARK_PRO_GIT_BRANCH}" ]]; then
    return
  fi

  local total_files=$(( _MODERN_DARK_PRO_GIT_FILES + _MODERN_DARK_PRO_GIT_UNTRACKED ))

  if [[ ${total_files} -eq 0 && ${_MODERN_DARK_PRO_GIT_INSERTIONS} -eq 0 && ${_MODERN_DARK_PRO_GIT_DELETIONS} -eq 0 ]]; then
    return
  fi

  # E.g. "5 • +97 -1"
  local content="${total_files}"
  
  if [[ ${_MODERN_DARK_PRO_GIT_INSERTIONS} -gt 0 || ${_MODERN_DARK_PRO_GIT_DELETIONS} -gt 0 ]]; then
    content+=" %F{#666666}•%f"
  fi
  
  if [[ ${_MODERN_DARK_PRO_GIT_INSERTIONS} -gt 0 ]]; then
    content+=" %F{${COLOR_SUCCESS}}+${_MODERN_DARK_PRO_GIT_INSERTIONS}%f"
  fi
  
  if [[ ${_MODERN_DARK_PRO_GIT_DELETIONS} -gt 0 ]]; then
    content+=" %F{${COLOR_ERROR}}-${_MODERN_DARK_PRO_GIT_DELETIONS}%f"
  fi

  if [[ ${_MODERN_DARK_PRO_GIT_UNTRACKED} -gt 0 && ${_MODERN_DARK_PRO_GIT_FILES} -eq 0 ]]; then
    content+=" %F{${COLOR_WARNING}}?${_MODERN_DARK_PRO_GIT_UNTRACKED}%f"
  fi

  _modern_dark_pro_make_pill "${COLOR_TEXT}" "${MODERN_DARK_PRO_CHANGES_SYMBOL}" "${content}"
}

function _modern_dark_pro_ssh_capsule() {
  if [[ -n "${SSH_CONNECTION}" || -n "${SSH_CLIENT}" || -n "${SSH_TTY}" ]]; then
    _modern_dark_pro_make_pill "${COLOR_WARNING}" "${MODERN_DARK_PRO_SSH_SYMBOL}" "%n@%m"
  fi
}

function _modern_dark_pro_venv_capsule() {
  local env_name=""
  if [[ -n "${VIRTUAL_ENV}" ]]; then
    env_name=$(basename "${VIRTUAL_ENV}")
  elif [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
    env_name="${CONDA_DEFAULT_ENV}"
  fi
  
  if [[ -n "${env_name}" ]]; then
    _modern_dark_pro_make_pill "#e6db74" "${MODERN_DARK_PRO_PYTHON_SYMBOL}" "${env_name}"
  fi
}

function _modern_dark_pro_node_capsule() {
  if [[ -n "${_MODERN_DARK_PRO_CACHED_NODE}" ]]; then
    _modern_dark_pro_make_pill "#81c784" "${MODERN_DARK_PRO_NODE_SYMBOL}" "${_MODERN_DARK_PRO_CACHED_NODE}"
  fi
}

function _modern_dark_pro_go_capsule() {
  if [[ -n "${_MODERN_DARK_PRO_CACHED_GO}" ]]; then
    _modern_dark_pro_make_pill "#4dd0e1" "${MODERN_DARK_PRO_GO_SYMBOL}" "${_MODERN_DARK_PRO_CACHED_GO}"
  fi
}

function _modern_dark_pro_rust_capsule() {
  if [[ -n "${_MODERN_DARK_PRO_CACHED_RUST}" ]]; then
    _modern_dark_pro_make_pill "#e57373" "${MODERN_DARK_PRO_RUST_SYMBOL}" "${_MODERN_DARK_PRO_CACHED_RUST}"
  fi
}

function _modern_dark_pro_tf_capsule() {
  if [[ -n "${_MODERN_DARK_PRO_CACHED_TF}" ]]; then
    _modern_dark_pro_make_pill "#ba68c8" "${MODERN_DARK_PRO_TF_SYMBOL}" "${_MODERN_DARK_PRO_CACHED_TF}"
  fi
}

function _modern_dark_pro_k8s_capsule() {
  local config_file="${KUBECONFIG:-$HOME/.kube/config}"
  if [[ -f "${config_file}" ]]; then
    local ctx
    ctx=$(grep 'current-context:' "${config_file}" 2>/dev/null | awk '{print $2}')
    if [[ -n "${ctx}" ]]; then
      _modern_dark_pro_make_pill "#64b5f6" "${MODERN_DARK_PRO_K8S_SYMBOL}" "${ctx}"
    fi
  fi
}

function _modern_dark_pro_aws_capsule() {
  if [[ -n "${AWS_PROFILE}" ]]; then
    local region="${AWS_DEFAULT_REGION:-${AWS_REGION}}"
    local display="${AWS_PROFILE}"
    [[ -n "${region}" ]] && display+="@${region}"
    _modern_dark_pro_make_pill "#ffb74d" "${MODERN_DARK_PRO_AWS_SYMBOL}" "${display}"
  fi
}

function _modern_dark_pro_jobs_capsule() {
  if [[ ${#jobstates} -gt 0 ]]; then
    _modern_dark_pro_make_pill "#ffb74d" "${MODERN_DARK_PRO_JOBS_SYMBOL}" "${#jobstates}"
  fi
}

function _modern_dark_pro_elapsed_capsule() {
  if [[ -n "${_MODERN_DARK_PRO_ELAPSED_TIME_VAL}" ]]; then
    _modern_dark_pro_make_pill "${COLOR_EXEC_TIME}" "${MODERN_DARK_PRO_TIME_SYMBOL}" "${_MODERN_DARK_PRO_ELAPSED_TIME_VAL}"
  fi
}

# Formats directory path based on MODERN_DARK_PRO_PATH_STYLE configuration
function _modern_dark_pro_path() {
  local style="${MODERN_DARK_PRO_PATH_STYLE:-limit}"
  local depth="${MODERN_DARK_PRO_PATH_DEPTH:-3}"
  
  if [[ "${style}" == "shrink" ]]; then
    local path_str="%~"
    # Expand %~ first to resolve standard Zsh prompt mapping
    path_str="${(%%)path_str}"
    
    local -a parts
    parts=(${(s:/:)path_str})
    local len=${#parts}
    
    # If path is just / or ~, return it directly
    if [[ ${len} -le 1 ]]; then
      echo -n "${path_str}"
      return
    fi
    
    local -a shrunk_parts
    for ((i=1; i<len; i++)); do
      local part="${parts[i]}"
      if [[ "${part}" == "~" ]]; then
        shrunk_parts+=("~")
      elif [[ "${part}" == "."* ]]; then
        shrunk_parts+=("${part:0:2}")
      else
        shrunk_parts+=("${part:0:1}")
      fi
    done
    shrunk_parts+=("${parts[len]}")
    
    local result="${(j:/:)shrunk_parts}"
    if [[ "${path_str:0:1}" == "/" && "${result:0:1}" != "/" ]]; then
      echo -n "/${result}"
    else
      echo -n "${result}"
    fi
  elif [[ "${style}" == "limit" ]]; then
    echo -n "%${depth}~"
  else
    echo -n "%~"
  fi
}

# Runtimes caching variables to keep prompt blazingly fast
_MODERN_DARK_PRO_LAST_PWD=""
_MODERN_DARK_PRO_CACHED_NODE=""
_MODERN_DARK_PRO_CACHED_GO=""
_MODERN_DARK_PRO_CACHED_RUST=""
_MODERN_DARK_PRO_CACHED_TF=""

# Updates runtimes versions only if PWD has changed (highly optimized)
function _modern_dark_pro_update_runtimes() {
  if [[ "${PWD}" == "${_MODERN_DARK_PRO_LAST_PWD}" ]]; then
    return
  fi
  _MODERN_DARK_PRO_LAST_PWD="${PWD}"

  # 1. Node.js
  _MODERN_DARK_PRO_CACHED_NODE=""
  if [[ -f package.json || -d node_modules ]]; then
    if (( $+commands[node] )); then
      _MODERN_DARK_PRO_CACHED_NODE=$(node -v 2>/dev/null)
    fi
  fi

  # 2. Go
  _MODERN_DARK_PRO_CACHED_GO=""
  local -a go_files
  go_files=( *.go(N) )
  if [[ -f go.mod ]] || (( ${#go_files} > 0 )); then
    if (( $+commands[go] )); then
      _MODERN_DARK_PRO_CACHED_GO=$(go env GOVERSION 2>/dev/null)
    fi
  fi

  # 3. Rust
  _MODERN_DARK_PRO_CACHED_RUST=""
  if [[ -f Cargo.toml ]]; then
    if (( $+commands[rustc] )); then
      local rust_v=$(rustc -V 2>/dev/null)
      _MODERN_DARK_PRO_CACHED_RUST="v${rust_v#*rustc }"
      _MODERN_DARK_PRO_CACHED_RUST="${_MODERN_DARK_PRO_CACHED_RUST%% *}"
    fi
  fi

  # 4. Terraform
  _MODERN_DARK_PRO_CACHED_TF=""
  local -a tf_files
  tf_files=( *.tf(N) )
  if [[ -f .terraform/environment ]]; then
    _MODERN_DARK_PRO_CACHED_TF=$(cat .terraform/environment 2>/dev/null)
  elif (( ${#tf_files} > 0 )); then
    _MODERN_DARK_PRO_CACHED_TF="default"
  fi
}

# Execution Time Measurement Hooks
function _modern_dark_pro_preexec() {
  if [[ "${MODERN_DARK_PRO_SHOW_EXEC_TIME}" == "true" ]]; then
    zmodload zsh/datetime
    _MODERN_DARK_PRO_START_TIME=$EPOCHREALTIME
  fi
}

function _modern_dark_pro_precmd() {
  local exit_code=$?
  
  # Calculate execution time
  local elapsed
  if [[ -n "${_MODERN_DARK_PRO_START_TIME}" ]]; then
    zmodload zsh/datetime
    local end_time=$EPOCHREALTIME
    (( elapsed = end_time - _MODERN_DARK_PRO_START_TIME ))
    unset _MODERN_DARK_PRO_START_TIME
    
    if (( elapsed >= MODERN_DARK_PRO_EXEC_TIME_MIN )); then
      if (( elapsed >= 60.0 )); then
        local mins secs
        (( mins = (int) (elapsed / 60) ))
        (( secs = (int) (elapsed) % 60 ))
        _MODERN_DARK_PRO_ELAPSED_TIME_VAL="${mins}m ${secs}s"
      else
        _MODERN_DARK_PRO_ELAPSED_TIME_VAL=$(printf "%.1fs" "${elapsed}")
      fi
    else
      _MODERN_DARK_PRO_ELAPSED_TIME_VAL=""
    fi
  else
    _MODERN_DARK_PRO_ELAPSED_TIME_VAL=""
  fi

  # Dynamic prompt character coloring based on success/failure
  if [[ $exit_code -eq 0 ]]; then
    _MODERN_DARK_PRO_PROMPT_CHAR="%F{${COLOR_SUCCESS}}${MODERN_DARK_PRO_CHAR}%f"
  else
    _MODERN_DARK_PRO_PROMPT_CHAR="%F{${COLOR_ERROR}}${MODERN_DARK_PRO_CHAR}%f"
  fi

  # Precompute expensive/dynamic prompt sections
  _modern_dark_pro_update_git
  _modern_dark_pro_update_runtimes
  _MODERN_DARK_PRO_PATH_VAL=$(_modern_dark_pro_path)
  
  # Set up the prompt layout dynamically
  _modern_dark_pro_setup_prompt
}

# Renders all active capsules in a space-separated sequence
function _modern_dark_pro_prompt_line() {
  local -a capsules
  local cap
  
  # SSH capsule first
  cap=$(_modern_dark_pro_ssh_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  # Path capsule
  cap=$(_modern_dark_pro_path_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  # Git branch capsule
  cap=$(_modern_dark_pro_git_branch_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  # Git changes capsule
  cap=$(_modern_dark_pro_git_changes_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  # Env / runtime capsules
  cap=$(_modern_dark_pro_venv_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  cap=$(_modern_dark_pro_node_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  cap=$(_modern_dark_pro_go_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  cap=$(_modern_dark_pro_rust_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  cap=$(_modern_dark_pro_tf_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  cap=$(_modern_dark_pro_k8s_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  cap=$(_modern_dark_pro_aws_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  # Jobs capsule
  cap=$(_modern_dark_pro_jobs_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  # Elapsed time capsule
  cap=$(_modern_dark_pro_elapsed_capsule)
  [[ -n "${cap}" ]] && capsules+=("${cap}")
  
  # Join with a single space
  echo -n "${(j: :)capsules}"
}

# Renders the first line of the prompt for "classic" layout with a dynamic right-aligned clock
function _modern_dark_pro_first_line() {
  local left="%F{${COLOR_CONNECTOR}}┌─%f $(_modern_dark_pro_prompt_line)"
  
  # Expand prompt escape sequences to compute visual width
  local expanded_left="${(%%)left}"
  
  # Strip ANSI color/style escape sequences from expanded left prompt
  setopt local_options extended_glob
  local clean_left="${expanded_left//$'\x1b'\[[0-9;]##[a-zA-Z]/}"
  local left_width=${(m)#clean_left}
  
  # Prepare the right-aligned clock block
  local right="%F{${COLOR_CONNECTOR}}${MODERN_DARK_PRO_TIME_SYMBOL} %D{%H:%M:%S}%f"
  local expanded_right="${(%%)right}"
  local clean_right="${expanded_right//$'\x1b'\[[0-9;]##[a-zA-Z]/}"
  local right_width=${(m)#clean_right}
  
  # Calculate required padding width (subtracting left/right width from terminal columns)
  local pad_width=$(( COLUMNS - left_width - right_width ))
  local padding=" "
  if (( pad_width > 1 )); then
    padding=""
    for ((i=1; i<=pad_width; i++)); do
      padding+=" "
    done
  fi
  
  echo -n "${left}${padding}${right}"
}

# Renders the first line for "two-line" layout, dynamically right-aligning the clock if enabled
function _modern_dark_pro_first_line_two_line() {
  local left="$(_modern_dark_pro_prompt_line)"
  
  if [[ "${MODERN_DARK_PRO_SHOW_CLOCK}" != "true" ]]; then
    echo -n "${left}"
    return
  fi
  
  # Expand prompt escape sequences to compute visual width
  local expanded_left="${(%%)left}"
  
  # Strip ANSI color/style escape sequences from expanded left prompt
  setopt local_options extended_glob
  local clean_left="${expanded_left//$'\x1b'\[[0-9;]##[a-zA-Z]/}"
  local left_width=${(m)#clean_left}
  
  # Prepare the right-aligned clock block
  local right="%F{${COLOR_CONNECTOR}}${MODERN_DARK_PRO_TIME_SYMBOL} %D{%H:%M:%S}%f"
  local expanded_right="${(%%)right}"
  local clean_right="${expanded_right//$'\x1b'\[[0-9;]##[a-zA-Z]/}"
  local right_width=${(m)#clean_right}
  
  # Calculate required padding width (subtracting left/right width from terminal columns)
  local pad_width=$(( COLUMNS - left_width - right_width ))
  local padding=" "
  if (( pad_width > 1 )); then
    padding=""
    for ((i=1; i<=pad_width; i++)); do
      padding+=" "
    done
  fi
  
  echo -n "${left}${padding}${right}"
}

# Sets up prompt and right prompt based on layout configuration
function _modern_dark_pro_setup_prompt() {
  local layout="${MODERN_DARK_PRO_PROMPT_LAYOUT:-two-line}"
  
  if [[ "${layout}" == "classic" ]]; then
    PROMPT='$(_modern_dark_pro_first_line)
%F{${COLOR_CONNECTOR}}└─%f ${_MODERN_DARK_PRO_PROMPT_CHAR} '
    RPROMPT=''
  elif [[ "${layout}" == "two-line" ]]; then
    PROMPT='$(_modern_dark_pro_first_line_two_line)
${_MODERN_DARK_PRO_PROMPT_CHAR} '
    RPROMPT=''
  else # single line layout
    PROMPT='$(_modern_dark_pro_prompt_line) ${_MODERN_DARK_PRO_PROMPT_CHAR} '
    if [[ "${MODERN_DARK_PRO_SHOW_CLOCK}" == "true" ]]; then
      RPROMPT='%F{#666666}${MODERN_DARK_PRO_TIME_SYMBOL} %D{%H:%M:%S}%f'
    else
      RPROMPT=''
    fi
  fi
}

# Zsh Hooks registration
autoload -Uz add-zsh-hook
add-zsh-hook preexec _modern_dark_pro_preexec
add-zsh-hook precmd _modern_dark_pro_precmd

# Initial prompt setup
_modern_dark_pro_setup_prompt
