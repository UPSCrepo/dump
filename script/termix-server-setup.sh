#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 Starting Cloud Phone Auto Setup..."

# Update system
pkg update -y && pkg upgrade -y

# Install required packages
pkg install -y python tmux openssh cloudflared ttyd

echo "✅ Packages installed"

# Start SSH server
sshd
echo "✅ SSH server started on port 8022"

# Show username
USER=$(whoami)
echo "👤 Username: $USER"

# Set password
echo "🔐 Set your password:"
passwd

# Start ttyd in background
echo "🌐 Starting web terminal..."
tmux new-session -d -s webterm "ttyd -W -c admin:admin123 bash"

sleep 2

# Start Cloudflare tunnel
echo "🌍 Starting Cloudflare Tunnel..."
cloudflared tunnel --url http://localhost:7681 > tunnel.log 2>&1 &

sleep 5

# Extract URL
URL=$(grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare.com' tunnel.log | head -n 1)

echo ""
echo "======================================"
echo "🎉 SETUP COMPLETE!"
echo "======================================"
echo "👤 SSH Username: $USER"
echo "🔐 SSH Password: (the one you set)"
echo ""
echo "🌐 Web Terminal URL:"
echo "$URL"
echo ""
echo "🔑 Web Terminal Login:"
echo "Username: admin"
echo "Password: admin123"
echo "======================================"