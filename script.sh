#!/bin/bash
set -euo pipefail

# The line with sed-and-xargs is a urldecoder
# `'sed 's|\\|\\\\|g'` makes all the \123 unicode escapes json-safe so we can
# jq.
for f in $(cat codes); do
  echo "$f" \
  | sed 's|QR-Code:otpauth-migration://offline?data=||' \
  | sed -e 's@+@ @g;s@%@\\x@g' | xargs -0 printf "%b" \
  | base64 -d \
  | protoc --decode MigrationPayload migration-payload.proto \
  | grep -e otp_parameters -e '}' -e secret: -e name: -e issuer \
  | sed 's/otp_parameters //' \
  | sed 's/  \([a-z]*\): \(.*\)/  "\1": \2,/' \
  | sed '/name":/ s/,$//' \
  | sed 's|\\|\\\\|g'
done \
  | while IFS= read -r line; do
  if [[ "$line" =~ secret ]]; then
    secret=$(printf %b "$(echo "$line" \
      | sed -e 's/  "secret": "\(.*\)",/\1/' -e 's|\\\\|\\|g')" \
      | base32)
    echo "  \"secret\": \"${secret}\","
  else
    echo "$line"
  fi
done \
  | while IFS= read -r line; do
  if [[ "$line" =~ secret ]]; then
    # shellcheck disable=SC2001
    secret=$(printf %b "$(echo "$line" \
      | sed -e 's/  "secret": "\(.*\)",/\1/')")
    totp=$(oathtool --totp --base32 "$secret")
    echo "  \"totp\": \"${totp}\","
    # echo "$line"
  else
    echo "$line"
  fi
done
