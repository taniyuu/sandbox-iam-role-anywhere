#!/bin/sh
set -eu

output_dir="${CERT_DIR:-/certs}"
mkdir -p "$output_dir"

# The CA is registered in the Trust anchor, so never overwrite it silently.
if [ -f "$output_dir/ca.crt" ] && [ -f "$output_dir/client.crt" ]; then
  printf 'Certificates already exist in %s, skipping\n' "$output_dir"
  exit 0
fi

umask 077

openssl genrsa -out "$output_dir/ca.key" 4096
openssl req -x509 -new -nodes -key "$output_dir/ca.key" -sha256 -days 365 \
  -out "$output_dir/ca.crt" \
  -subj "/C=JP/O=Local IAM Roles Anywhere Demo/CN=local-demo-ca" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign"

openssl genrsa -out "$output_dir/client.key" 2048
openssl req -new -key "$output_dir/client.key" -out "$output_dir/client.csr" \
  -subj "/C=JP/O=Local IAM Roles Anywhere Demo/CN=container-client"

cat > "$output_dir/client.ext" <<'EOF'
basicConstraints=CA:FALSE
keyUsage=digitalSignature
extendedKeyUsage=clientAuth
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EOF

openssl x509 -req -in "$output_dir/client.csr" -CA "$output_dir/ca.crt" \
  -CAkey "$output_dir/ca.key" -CAcreateserial -out "$output_dir/client.crt" \
  -days 365 -sha256 -extfile "$output_dir/client.ext"

rm -f "$output_dir/client.csr" "$output_dir/client.ext" "$output_dir/ca.srl"
chmod 0600 "$output_dir"/*.key
chmod 0644 "$output_dir"/*.crt
printf 'Created self-signed CA and client certificate in %s\n' "$output_dir"