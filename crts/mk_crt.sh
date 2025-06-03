#!/bin/bash

# 設定憑證參數
COUNTRY="TW"
STATE="Taiwan"
LOCALITY="Taipei"
ORGANIZATION="MyCompany"
ORG_UNIT="IT"
COMMON_NAME="*.ican"
DAYS_VALID=365000

# 檔名設定
KEY_FILE="ican.key"
CSR_FILE="ican.csr"
CRT_FILE="ican.crt"
CONFIG_FILE="ican_openssl.cnf"

# 產生 OpenSSL 設定檔（含 SAN）
cat > $CONFIG_FILE <<EOF
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[dn]
C=$COUNTRY
ST=$STATE
L=$LOCALITY
O=$ORGANIZATION
OU=$ORG_UNIT
CN=$COMMON_NAME

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.ican
DNS.2 = ican
DNS.3 = registry.ican
DNS.4 = registry.nas.ican
EOF

echo "🔐 產生私鑰..."
openssl genrsa -out $KEY_FILE 2048

echo "📄 產生 CSR（簽署請求）..."
openssl req -new -key $KEY_FILE -out $CSR_FILE -config $CONFIG_FILE

echo "✅ 產生自簽名憑證，有效期 $DAYS_VALID 天..."
openssl x509 -req -in $CSR_FILE -signkey $KEY_FILE -out $CRT_FILE -days $DAYS_VALID -extfile $CONFIG_FILE -extensions req_ext

echo "🎉 憑證產生完成："
echo "🔑 私鑰: $KEY_FILE"
echo "📄 憑證: $CRT_FILE"
