#!/bin/sh
# shellcheck disable=SC3010
# SC3010 - busybox supports [[ ]]

if [[ "${FOUNDRY_SSL_CERT:-}" && "${FOUNDRY_SSL_KEY:-}" ]]; then
  protocol="https"
  port="443"
else
  protocol="http"
  port="80"
fi

if [[ "${FOUNDRY_ROUTE_PREFIX:-}" ]]; then
  STATUS_URL="${protocol}://localhost:${port}/${FOUNDRY_ROUTE_PREFIX}/api/status"
else
  STATUS_URL="${protocol}://localhost:${port}/api/status"
fi

/usr/bin/curl --cookie-jar healthcheck-cookiejar.txt \
  --cookie healthcheck-cookiejar.txt --insecure --fail --silent \
  "${STATUS_URL}" || exit 1
