#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_dir="$(cd -- "$script_dir/../Packages/KubarOKCore" && pwd)"

cleanup() {
  unset KUBAROK_REGISTER_NAME
  unset KUBAROK_REGISTER_PHONE
  unset KUBAROK_REGISTER_EMAIL
  unset KUBAROK_REGISTER_PASSWORD
  unset KUBAROK_LOGIN
  unset KUBAROK_PASSWORD
  unset KUBAROK_DEVICE_TOKEN
}

trap cleanup EXIT

printf '%s\n' '========================================'
printf '%s\n' 'KUBAROK IOS DEVELOPMENT ACCOUNT'
printf '%s\n' '========================================'
printf '\n'

read -r -p 'Nama: ' KUBAROK_REGISTER_NAME
read -r -p 'Email: ' KUBAROK_REGISTER_EMAIL
read -r -p 'Nomor HP: ' KUBAROK_REGISTER_PHONE
read -r -s -p 'Password: ' KUBAROK_REGISTER_PASSWORD
printf '\n'
read -r -s -p 'Konfirmasi Password: ' confirmation_password
printf '\n'
read -r -p 'Device token (optional): ' KUBAROK_DEVICE_TOKEN

if [[ "$KUBAROK_REGISTER_PASSWORD" != "$confirmation_password" ]]; then
  unset confirmation_password
  printf '%s\n' 'Password tidak sama.'
  exit 1
fi

unset confirmation_password

export KUBAROK_REGISTER_NAME
export KUBAROK_REGISTER_PHONE
export KUBAROK_REGISTER_EMAIL
export KUBAROK_REGISTER_PASSWORD
export KUBAROK_DEVICE_TOKEN

cd "$package_dir"

printf '\n%s\n\n' 'Registering account...'
docker run --rm \
  -e KUBAROK_REGISTER_NAME \
  -e KUBAROK_REGISTER_PHONE \
  -e KUBAROK_REGISTER_EMAIL \
  -e KUBAROK_REGISTER_PASSWORD \
  -e KUBAROK_DEVICE_TOKEN \
  -v "$PWD:/workspace" \
  -w /workspace \
  swift:6.3.3 \
  swift run KubarOKRegistrationTest

KUBAROK_LOGIN="$KUBAROK_REGISTER_EMAIL"
KUBAROK_PASSWORD="$KUBAROK_REGISTER_PASSWORD"
export KUBAROK_LOGIN
export KUBAROK_PASSWORD

printf '\n%s\n\n' 'Logging in...'
docker run --rm \
  -e KUBAROK_LOGIN \
  -e KUBAROK_PASSWORD \
  -e KUBAROK_DEVICE_TOKEN \
  -v "$PWD:/workspace" \
  -w /workspace \
  swift:6.3.3 \
  swift run KubarOKAuthTest
