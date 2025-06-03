#!/bin/bash

CERT_NAME="ican.crt"
TRUSTED_CERT_NAME="ican.crt"
TRUSTED_CERT_DIR="/usr/local/share/ca-certificates"
CONTAINERD_CA_DIR="/etc/containerd/certs.d/registry.ican/"

# 確認執行權限
if [ "$EUID" -ne 0 ]; then
  echo "❌ 請使用 sudo 權限執行本腳本。"
  exit 1
fi

# 檢查憑證檔是否存在
if [ ! -f "$CERT_NAME" ]; then
  echo "❌ 找不到憑證檔案：$CERT_NAME"
  exit 1
fi

if [ -e '/etc/containerd' ]; then
  mkdir -p /etc/containerd/certs.d/registry.ican/
  cp -r ./ican.crt $CONTAINERD_CA_DIR
#   sudo sed -i '/\[plugins."io.containerd.grpc.v1.cri".registry\]/,/^\[.*\]/s/^ *config_path *= *".*"//' /etc/containerd/config.toml
#   sudo sed -i '/\[plugins."io.containerd.grpc.v1.cri".registry\]/a\
# \tconfig_path = "/etc/containerd/certs.d"' /etc/containerd/config.toml
  sudo sed -i '/\[plugins."io.containerd.grpc.v1.cri".registry.mirrors\]/a\
  \t[plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.ican"]\n\t\tendpoint = ["https://registry.ican"]' /etc/containerd/config.toml
fi

echo "📥 複製憑證到系統信任目錄..."
cp "$CERT_NAME" "$TRUSTED_CERT_DIR/$TRUSTED_CERT_NAME"

echo "🔄 更新系統憑證信任庫..."
update-ca-certificates

echo "✅ 憑證已成功安裝為受信任的根憑證："
echo "   - 檔案路徑：$TRUSTED_CERT_DIR/$TRUSTED_CERT_NAME"
service containerd restart
