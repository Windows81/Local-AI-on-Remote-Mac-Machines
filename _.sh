#!/bin/sh
cd $HOME/Downloads

curl https://ollama.com/download/Ollama-darwin.zip --location --output Ollama.zip --no-clobber && unzip -n Ollama.zip
OLLAMA_HOST="0.0.0.0:11434"

curl https://github.com/aploium/shootback/archive/refs/heads/master.zip --location --output Shootback.zip --no-clobber && unzip -n Shootback.zip

python3 shootback-master/slaver.py -m 192.168.62.107:8080 -t 127.0.0.1:11434 &
pid_shootback=$!
echo "-  Shootback:" $pid_shootback

Ollama.app/Contents/Resources/ollama pull gpt-oss:20b
pkill ollama
Ollama.app/Contents/Resources/ollama serve &
pid_ollama=$!
echo "-     Ollama:" $pid_ollama

(osascript <<EOF
repeat while true
  delay 5
  tell application "System Events" to tell process "Terminal" to set frontmost to true
end repeat
EOF
)&
pid_osascript=$!
echo "- AppleScript:" $pid_osascript

osascript -e 'display dialog "I am running a local LLM on this machine and proxying the machine back home. Please call or text +1 714 463 5142 before closing any programs." with title "A word of caution before logging off"'
