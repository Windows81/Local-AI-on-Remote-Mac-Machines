#!/bin/sh

SHOOTBACK_DEST=`netstat -rn | grep -m 1 en1 | grep -Eo 192[\.0-9]+`
MODELS_TO_DOWNLOAD=("qwen2.5-coder:1.5b" "qwen3-coder:30b")
LOG_PREFIX="ollama-mac-log-`date +%s`"
cd $HOME/Downloads

download_file() {
  if ! [ -f "$1" ]; then
    curl --location --output "$1" "$2"
  fi
}

python_prepare() {
  download_file Python.pkg "https://github.com/macadmins/python/releases/download/v3.12.1.80742/python_recommended_signed-3.12.1.80742.pkg"
  pkgutil --expand-full Python.pkg python-cli
  new_path=`realpath python-cli/python_*.pkg/Payload/Library/ManagedFrameworks/Python/Python3.framework/Versions/*/bin | head -n 1`
  export PATH="$new_path${PATH:+:${PATH}}"
}

ollama_prepare() {
  download_file Ollama.zip "https://ollama.com/download/Ollama-darwin.zip" && unzip -n Ollama.zip
  new_path=`realpath Ollama.app/Contents/Resources/`
  export PATH="$new_path${PATH:+:${PATH}}"
}

python_prepare
ollama_prepare

python_shootback_ready() {
  download_file Shootback.zip "https://github.com/aploium/shootback/archive/refs/heads/master.zip"
  unzip -n Shootback.zip

  python3 shootback-master/slaver.py -m $SHOOTBACK_DEST:10000 -t 127.0.0.1:11434 >$LOG_PREFIX-shootback.log 2>&1 &
  pid_shootback=$!
  echo "-  Shootback:" $pid_shootback
}

ollama_ready() {
  OLLAMA_HOST="0.0.0.0:11434"
  ollama serve >$LOG_PREFIX-ollama.log 2>&1 &
  pid_ollama=$!
  echo "-     Ollama:" $pid_ollama

  echo ${MODELS_TO_DOWNLOAD[@]} | xargs -n 1 ollama pull
}

python_shootback_ready
ollama_ready

osascript -e 'display dialog "I am running a local LLM on this machine and proxying the machine back home. Please call or text +1 714 463 5142 before closing any programs." with title "A word of caution before logging off"'
