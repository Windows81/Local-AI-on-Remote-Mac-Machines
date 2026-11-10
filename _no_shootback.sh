#!/bin/sh
trap 'kill 0' EXIT
cd /System/Volumes/Data/Volumes/demouser || cd $HOME/Downloads

MODELS_TO_DOWNLOAD=("gemma4:12b-mlx" "qwen3.8:27b")
LOG_PREFIX="ollama-mac-log-`date +%s`"

download_file() {
  if ! [ -f "$1" ]; then
    curl --location --output "$1" "$2"
  fi
}

ollama_prepare() {
  download_file Ollama.zip "https://ollama.com/download/Ollama-darwin.zip" && unzip -n Ollama.zip
  new_path=`realpath Ollama.app/Contents/Resources/`
  export PATH="$new_path${PATH:+:${PATH}}"
}

ollama_prepare

ollama_ready() {
  OLLAMA_HOST="0.0.0.0:11434"
  ollama serve >$LOG_PREFIX-ollama.log 2>&1 &
  pid_ollama=$!
  echo "- Ollama:" $pid_ollama

  echo ${MODELS_TO_DOWNLOAD[@]} | xargs -n 1 ollama pull
}

ollama_ready

osascript -e 'display dialog "I am running a local LLM on this machine and proxying the machine back home. Please call or text +1 714 463 5142 before closing any programs." with title "A word of caution before logging off"'

pkill -P $$
