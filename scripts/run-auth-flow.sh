#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_dir="$(cd -- "$script_dir/../Packages/KubarOKCore" && pwd)"

cleanup() {
  unset KUBAROK_LOGIN
  unset KUBAROK_PASSWORD
  unset KUBAROK_DEVICE_TOKEN
}

trap cleanup EXIT

read -r -p "Login KubarOK (email/no HP): " KUBAROK_LOGIN
read -r -s -p "Password KubarOK: " KUBAROK_PASSWORD
printf '\n'
read -r -p "Device token (optional): " KUBAROK_DEVICE_TOKEN

export KUBAROK_LOGIN
export KUBAROK_PASSWORD
export KUBAROK_DEVICE_TOKEN

cd "$package_dir"

docker run --rm \
  -e KUBAROK_LOGIN \
  -e KUBAROK_PASSWORD \
  -e KUBAROK_DEVICE_TOKEN \
  -v "$PWD:/workspace" \
  -w /workspace \
  swift:6.3.3 \
  swift run KubarOKAuthFlowTest
