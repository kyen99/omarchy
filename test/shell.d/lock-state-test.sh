#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /function refreshLockedState\(\) \{\s*root\.locked = root\.lockRequested \|\| sessionLock\.locked\s*\}/.test(serviceQml),
  'lock state is refreshed explicitly from the requested and session states'
)

assert(
  /onLockRequestedChanged: root\.refreshLockedState\(\)/.test(serviceQml),
  'a local lock request refreshes the derived state immediately'
)

assert(
  /onLockStateChanged: \{\s*\/\/[^\n]*\n\s*Qt\.callLater\(root\.refreshLockedState\)/.test(serviceQml),
  'a session lock transition refreshes state after its new value becomes observable'
)

assert(
  !/root\.locked =[^\n]*sessionLock\.secure/.test(serviceQml),
  'the derived lock state does not depend on the late secure transition'
)
JS
