#!/usr/bin/env bash
set -euo pipefail

# CalDAV incremental sync (sync-collection) demo against local server.
# Prérequis : serveur Lyxal_Dav en écoute sur http://localhost:8080/dav

BASE_URL="${BASE_URL:-http://localhost:8080/dav}"
CAL_PATH="${CAL_PATH:-/calendars/test/default}"
AUTH="${AUTH:-user:password}"

echo "1) PROPFIND initial pour récupérer le sync-token"
TOKEN=$(
  curl -s -X PROPFIND \
    -u "${AUTH}" \
    -H "Depth: 0" \
    -H "Content-Type: application/xml" \
    --data '<D:propfind xmlns:D="DAV:"><D:prop><D:sync-token/></D:prop></D:propfind>' \
    "${BASE_URL}${CAL_PATH}" |
  grep -o "<D:sync-token>[^<]*" | sed 's#<D:sync-token>##'
)
echo "Sync-token initial: ${TOKEN:-<none>}"

echo "2) PUT d'un événement"
cat > /tmp/demo.ics <<'EOF'
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Lyxal//DAV Demo//EN
BEGIN:VEVENT
UID:demo-sync-1
DTSTAMP:20250101T000000Z
DTSTART:20250102T100000Z
DTEND:20250102T110000Z
SUMMARY:Demo sync create
END:VEVENT
END:VCALENDAR
EOF
curl -s -X PUT -u "${AUTH}" \
  -H "Content-Type: text/calendar" \
  --data-binary @/tmp/demo.ics \
  "${BASE_URL}${CAL_PATH}/demo.ics" >/dev/null

echo "3) REPORT sync-collection (attendu: création)"
curl -s -X REPORT -u "${AUTH}" \
  -H "Depth: 1" \
  -H "Content-Type: application/xml" \
  --data "<sync-collection xmlns=\"DAV:\" xmlns:C=\"urn:ietf:params:xml:ns:caldav\"><sync-token>${TOKEN}</sync-token><sync-level>1</sync-level><prop><getetag/><C:calendar-data/></prop></sync-collection>" \
  "${BASE_URL}${CAL_PATH}" | tee /tmp/report1.xml

echo "4) DELETE de l'événement"
curl -s -X DELETE -u "${AUTH}" "${BASE_URL}${CAL_PATH}/demo.ics" >/dev/null

echo "5) REPORT sync-collection (attendu: delete 404)"
curl -s -X REPORT -u "${AUTH}" \
  -H "Depth: 1" \
  -H "Content-Type: application/xml" \
  --data "<sync-collection xmlns=\"DAV:\" xmlns:C=\"urn:ietf:params:xml:ns:caldav\"><sync-token>${TOKEN}</sync-token><sync-level>1</sync-level><prop><getetag/></prop></sync-collection>" \
  "${BASE_URL}${CAL_PATH}" | tee /tmp/report2.xml

echo "Fini. Inspectez /tmp/report1.xml et /tmp/report2.xml pour vérifier les réponses."

