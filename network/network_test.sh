# One-time check
pid=$(pgrep ollama)
lsof -i -P -n | grep ollama

# Or for continuous monitoring
watch -n 2 "lsof -i -P -n | grep ollama"

# Alternative using netstat
netstat -np | grep ollama

# Or using ss (more modern)
ss -np | grep ollama
