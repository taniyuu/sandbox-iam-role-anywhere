#!/bin/sh
set -eu

: "${ROLE_ARN:?ROLE_ARN is required}"
: "${PROFILE_ARN:?PROFILE_ARN is required}"
: "${TRUST_ANCHOR_ARN:?TRUST_ANCHOR_ARN is required}"

mkdir -p /run/rolesanywhere
cat > /run/rolesanywhere/aws-config <<EOF
[profile rolesanywhere]
credential_process = /usr/local/bin/aws_signing_helper credential-process --certificate /run/rolesanywhere/certs/client.crt --private-key /run/rolesanywhere/certs/client.key --trust-anchor-arn ${TRUST_ANCHOR_ARN} --profile-arn ${PROFILE_ARN} --role-arn ${ROLE_ARN}
EOF
chmod 0600 /run/rolesanywhere/aws-config

exec java -jar /app/app.jar