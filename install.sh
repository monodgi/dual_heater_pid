cat > install.sh << 'EOF'
#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
EXTRAS_DIR="$HOME/klipper/klippy/extras"
LOG_FILE="$HOME/printer_data/logs/klippy.log"

echo "=== Dual Heater Plugin Deploy ==="

if [ ! -d "$EXTRAS_DIR" ]; then
    echo "ERROR: Klipper extras not found at $EXTRAS_DIR"
    exit 1
fi

ARCH=$(uname -m)
echo "Detected arch: $ARCH"

echo "[1/2] Copying binaries..."
cp "$REPO_DIR"/serial_dual_heater*.so "$EXTRAS_DIR/" 2>/dev/null || true
cp "$REPO_DIR"/serial_dual_heater.py "$EXTRAS_DIR/"
cp "$REPO_DIR"/serial_dual_heater_calibrate*.so "$EXTRAS_DIR/" 2>/dev/null || true
cp "$REPO_DIR"/serial_dual_heater_calibrate.py "$EXTRAS_DIR/"
cp "$REPO_DIR"/average_thermistor*.so "$EXTRAS_DIR/" 2>/dev/null || true
cp "$REPO_DIR"/average_thermistor.py "$EXTRAS_DIR/" 2>/dev/null || true

echo "[2/2] Cleaning cache..."
rm -rf "$EXTRAS_DIR"/__pycache__/

echo "Restarting Klipper..."
sudo systemctl restart klipper

sleep 3
if grep -q "UnifiedDualHeater: A control replaced" "$LOG_FILE" 2>/dev/null; then
    echo ""
    echo "✅ Deploy successful!"
else
    echo ""
    echo "⚠️  Check logs: tail -n 20 $LOG_FILE"
fi

echo ""
echo "=== Done ==="
ls -la "$EXTRAS_DIR"/serial_dual_heater* "$EXTRAS_DIR"/average_thermistor* 2>/dev/null || true
EOF

chmod +x install.sh
