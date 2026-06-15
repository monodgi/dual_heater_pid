#!/bin/bash
# install.sh - 一键部署双加热器统一控制插件
# 自动检测 Klipper 路径，复制文件到 extras 根目录，重启服务

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
EXTRAS_DIR="$HOME/klipper/klippy/extras"
LOG_FILE="$HOME/printer_data/logs/klippy.log"

echo "=== Dual Heater Plugin Deploy ==="

# 1. 自动检测 Klipper 路径
if [ ! -d "$EXTRAS_DIR" ]; then
    echo "ERROR: Klipper extras not found at $EXTRAS_DIR"
    echo "Please install Klipper first."
    exit 1
fi

# 2. 复制 .so + 壳文件到 extras 根目录（不是子文件夹！）
echo "[1/2] Copying to $EXTRAS_DIR ..."

cp "$REPO_DIR"/serial_dual_heater*.so "$EXTRAS_DIR/" 2>/dev/null || true
cp "$REPO_DIR"/serial_dual_heater.py "$EXTRAS_DIR/"

cp "$REPO_DIR"/serial_dual_heater_calibrate*.so "$EXTRAS_DIR/" 2>/dev/null || true
cp "$REPO_DIR"/serial_dual_heater_calibrate.py "$EXTRAS_DIR/"

cp "$REPO_DIR"/average_thermistor*.so "$EXTRAS_DIR/" 2>/dev/null || true
cp "$REPO_DIR"/average_thermistor.py "$EXTRAS_DIR/" 2>/dev/null || true

# 3. 清理缓存
echo "[2/2] Cleaning cache..."
rm -rf "$EXTRAS_DIR"/__pycache__/

# 4. 重启 Klipper
echo "Restarting Klipper..."
sudo systemctl restart klipper

# 5. 验证
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
echo "Files in extras:"
ls -la "$EXTRAS_DIR"/serial_dual_heater*.so "$EXTRAS_DIR"/serial_dual_heater*.py 2>/dev/null || true
