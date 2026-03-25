#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 Starting Cloud Phone Auto Setup..."

# ---------- FIX REPO ----------
echo "🔧 Fixing repository..."
termux-change-repo >/dev/null 2>&1 || true

# ---------- UPDATE SYSTEM ----------
echo "📦 Updating system..."
pkg update -y && pkg upgrade -y

# ---------- FIX CURL (IMPORTANT) ----------
echo "🔧 Fixing curl if broken..."
rm -rf $PREFIX/lib/libcurl* 2>/dev/null
pkg reinstall openssl -y
pkg reinstall curl -y || pkg install curl -y

# ---------- INSTALL BASIC TOOLS ----------
echo "📦 Installing required packages..."
pkg install -y python tmux openssh cloudflared ttyd wget

echo "✅ Packages installed"

# ---------- START SSH ----------
echo "🔐 Starting SSH server..."
sshd

USER=$(whoami)
echo "👤 Username: $USER"

echo "🔑 Set your SSH password:"
passwd

# ---------- GENERATE RANDOM PASSWORD ----------
PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)

# ---------- START TTYD ----------
echo "🌐 Starting web terminal..."
tmux new-session -d -s webterm "ttyd -W -c admin:$PASS bash"

sleep 2

# ---------- START CLOUDFLARE ----------
echo "🌍 Starting Cloudflare tunnel..."
cloudflared tunnel --url http://localhost:7681 > tunnel.log 2>&1 &

# ---------- WAIT FOR URL ----------
echo "⏳ Waiting for tunnel URL..."
for i in {1..10}; do
  sleep 2
  URL=$(grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare.com' tunnel.log | head -n 1)
  if [ ! -z "$URL" ]; then
    break
  fi
done

# ---------- OUTPUT ----------
echo ""
echo "======================================"
echo "🎉 SETUP COMPLETE!"
echo "======================================"
echo "👤 SSH Username: $USER"
echo "🔐 SSH Password: (the one you set)"
echo ""
echo "🌐 Web Terminal URL:"
echo "${URL:-⚠️ Not detected (run manually)}"
echo ""
echo "🔑 Web Terminal Login:"
echo "Username: admin"
echo "Password: $PASS"
echo "======================================"

# ---------- FALLBACK ----------
if [ -z "$URL" ]; then
  echo ""
  echo "⚠️ If URL not shown, run manually:"
  echo "cloudflared tunnel --url http://localhost:7681"
fi