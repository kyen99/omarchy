#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /readonly property bool locked: lockRequested \|\| sessionLock\.secure/.test(serviceQml),
  'lock state follows the requested lock and the compositor secure signal'
)

assert(
  !/readonly property bool locked:[^\n]*sessionLock\.locked/.test(serviceQml),
  'lock state does not bind sessionLock.locked, which stays stale after unlock'
)

assert(
  /function requestSessionLock\(\) \{\s*if \(!lockRequested \|\| sessionLock\.secure\) return/.test(serviceQml),
  'a later lock request is not skipped just because sessionLock.locked is stale'
)

assert(
  /function lock\(\): string \{[\s\S]*if \(root\.lockRequested \|\| sessionLock\.secure\) return "ok"/.test(serviceQml),
  'IPC lock retries unless a lock is already requested or secure'
)

assert(
  /onSecureStateChanged: \{[\s\S]*else \{\s*root\.handleSessionUnlocked\(\)/.test(serviceQml),
  'losing the compositor secure state clears a local lock request'
)
JS
