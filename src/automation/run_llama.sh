#!/usr/bin/env bash

set -o pipefail

# =========================
# Active Model Profile
# =========================

ACTIVE_PROFILE="mistral"

# =========================
# Global Configuration
# =========================

LLAMACPP_REPO_PATH="${LLAMACPP_REPO_PATH:-/home/developer/Documents/llama.cpp}"

LLAMA_SERVER_BIN="${LLAMACPP_REPO_PATH}/build/bin/llama-server"

USE_JINJA=1

# Runtime
SERVER_PID=""

# =========================
# Model Profiles
# =========================

profile_qwen() {
  MODEL_PATH="${LLAMACPP_REPO_PATH}/qwen2.5-1.5b-instruct-q5_k_m.gguf"

  # Offload N layers to GPU (99 = all layers)
  NGL=99
  # Flash Attention (memory optimization)
  FA="auto"
  # Slot matching mode (optimization, keep as is)
  SM="row"

  # Lower (0.3-0.5) = more focused/reliable. Higher (0.7-1.0) = more creative
  TEMP=0.6

  # Consider only top-K most likely next words
  # Lower = more focused (10-20). Higher = more variety (30-50)
  TOP_K=20
  # Cumulative probability threshold
  # Lower (0.8-0.9) = more focused. Higher (0.95-1.0) = more variety
  TOP_P=0.95
  # Minimum probability threshold
  # Keep at 0 for most use cases
  MIN_P=0

  # Context window (how much text it remembers)
  CTX=32768

  # Max tokens to generate in one response
  N_PRED=32768

  R_PENALTY=1.1 # penalize repeat sequence of tokens (default: 1.00, 1.0 = disabled)
  P_PENALTY=0.0 # repeat alpha presence penalty (default: 0.00, 0.0 = disabled)

  # Output format for structured reasoning (model-dependent)
  REASONING_FORMAT="deepseek"
}

# worst currenty
profile_wizardcoder() {
  MODEL_PATH="${LLAMACPP_REPO_PATH}/wizardcoder-python-7b-v1.0.Q4_K_M.gguf"

  NGL=40
  FA="auto"
  SM="row"

  TEMP=0.2
  TOP_K=40
  TOP_P=0.90
  MIN_P=0

  CTX=4192
  N_PRED=1096

  REASONING_FORMAT="none"
}

# Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf
profile_qwen_coder() {
  MODEL_PATH="${LLAMACPP_REPO_PATH}/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"

  NGL=30
  FA="auto"
  SM="row"

  TEMP=0.7
  TOP_K=20
  TOP_P=0.80
  MIN_P=0

  CTX=16384
  N_PRED=4096
  #TODO add -ctk q4_0

  REASONING_FORMAT="none"
}

# Qwen3.5-9B-Q4_K_M.gguf
profile_qwen35() {
  MODEL_PATH="${LLAMACPP_REPO_PATH}/Qwen3.5-9B-Q4_K_M.gguf"

  NGL=30
  FA="auto"
  SM="row"

  TEMP=0.6
  TOP_K=20
  TOP_P=0.95
  MIN_P=0

  CTX=16384
  N_PRED=4096

  R_PENALTY=1.0
  P_PENALTY=0.0
  #TODO add -ctk q4_0
  # --presence-penalty 0.0
  # --repeat-penalty 1.0

  REASONING_FORMAT="none"
}

# ./main -ngl 35 -m mistral-7b-instruct-v0.2.Q4_K_M.gguf --color -c 32768 --temp 0.7 --repeat_penalty 1.1 -n -1 -p "<s>[INST] {prompt} [/INST]"
profile_mistral() {
  MODEL_PATH="${LLAMACPP_REPO_PATH}/mistral-7b-instruct-v0.2.Q4_K_M.gguf"

  NGL=35
  FA="auto"
  SM="row"

  TEMP=0.7
  TOP_K=20
  TOP_P=0.95
  MIN_P=0

  CTX=16384
  N_PRED=-1

  R_PENALTY=1.1 # penalize repeat sequence of tokens (default: 1.00, 1.0 = disabled)
  P_PENALTY=0.0 # repeat alpha presence penalty (default: 0.00, 0.0 = disabled)

  REASONING_FORMAT="none"
}

# =========================
# Utility Functions
# =========================

log_info() {
  printf '%s\n' "$1"
}

log_error() {
  printf '%s\n' "$1" >&2
}

validate_file() {
  local file="$1"

  [[ -n "$file" ]] || {
    log_error "File path is empty"
    return 1
  }

  [[ -f "$file" ]] || {
    log_error "File not found: $file"
    return 1
  }

  return 0
}

validate_binary() {
  local bin="$1"

  [[ -n "$bin" ]] || {
    log_error "Binary path is empty"
    return 1
  }

  [[ -x "$bin" ]] || {
    log_error "Binary not executable or not found: $bin"
    return 1
  }

  return 0
}

# =========================
# Profile Loader
# =========================

load_profile() {
  case "$ACTIVE_PROFILE" in
  qwen)
    profile_qwen
    ;;
  wizardcoder)
    profile_wizardcoder
    ;;
  qwen_coder)
    profile_qwen_coder
    ;;
  qwen35)
    profile_qwen35
    ;;
  mistral)
    profile_mistral
    ;;
  *)
    log_error "Unknown profile: $ACTIVE_PROFILE"
    return 1
    ;;
  esac

  log_info "Profile : $ACTIVE_PROFILE"
  log_info "Model   : $MODEL_PATH"
}

# =========================
# Command Builder
# =========================

build_command() {
  local cmd=()

  cmd=(
    "$LLAMA_SERVER_BIN"
    -m "$MODEL_PATH"
    -ngl "$NGL"
    -fa "$FA"
    -sm "$SM"
    --temp "$TEMP"
    --top-k "$TOP_K"
    --top-p "$TOP_P"
    --min-p "$MIN_P"
    -c "$CTX"
    -n "$N_PRED"
    --presence-penalty "$P_PENALTY"
    --repeat-penalty "$R_PENALTY"
    # Disable sliding window to preserve full context (uses more VRAM)
    --no-context-shift
  )

  # Enable Jinja2 templating for prompts (usually leave on)
  if [[ "$USE_JINJA" -eq 1 ]]; then
    cmd+=(--jinja)
  fi

  if [[ -n "$REASONING_FORMAT" && "$REASONING_FORMAT" != "none" ]]; then
    cmd+=(--reasoning-format "$REASONING_FORMAT")
  fi

  printf '%q ' "${cmd[@]}"
  printf '\n'
}

# =========================
# Server
# =========================

start_server() {
  local cmd_string

  cmd_string="$(build_command)"

  # enable ram usage when vram not enough
  export GGML_CUDA_ENABLE_UNIFIED_MEMORY=1

  log_info ""
  log_info "Starting llama-server..."
  log_info ""
  log_info "$cmd_string"
  log_info ""

  eval "$cmd_string" &
  SERVER_PID=$!

  wait "$SERVER_PID"
}

cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    log_info "Stopping llama-server (PID: $SERVER_PID)"
    kill "$SERVER_PID" 2>/dev/null
  fi
}

init_traps() {
  trap cleanup INT TERM EXIT
}

validate_environment() {
  validate_binary "$LLAMA_SERVER_BIN" || return 1
  validate_file "$MODEL_PATH" || return 1
}

# =========================
# Main
# =========================

main() {
  init_traps

  load_profile || return 1

  validate_environment || {
    log_error "Environment validation failed"
    return 1
  }

  start_server
}

main "$@"
