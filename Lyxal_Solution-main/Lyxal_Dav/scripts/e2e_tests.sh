#!/bin/bash
# E2E Test Suite for Lyxal_Dav
# Requires server running on port 3000
# Usage: ./e2e_tests.sh

HOST="http://127.0.0.1:3000"
USER="user"
PASS="password"
AUTH="$USER:$PASS"

echo "=== Lyxal_Dav E2E Tests ==="
echo "Target: $HOST"

# Function to check http status
check_status() {
    if [ "$1" -ne "$2" ]; then
        echo "FAIL: Expected status $2, got $1"
        exit 1
    fi
    echo "OK ($1)"
}

# 1. CalDAV: Create Calendar
echo "--- [1] Create Calendar ---"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X MKCALENDAR -u "$AUTH" "$HOST/calendars/user/e2e-cal")
if [ "$STATUS" -eq 201 ] || [ "$STATUS" -eq 405 ]; then # 405 if already exists (idempotent)
    echo "OK ($STATUS)"
else
    echo "FAIL: $STATUS"
    exit 1
fi

# 2. CalDAV: Put Event
echo "--- [2] Create Event ---"
EVENT="BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
UID:e2e-1
DTSTART:20250101T120000Z
SUMMARY:E2E Event
END:VEVENT
END:VCALENDAR"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -u "$AUTH" -H "Content-Type: text/calendar" -d "$EVENT" "$HOST/calendars/user/e2e-cal/evt1.ics")
check_status "$STATUS" 201 # Or 204 if update

# 3. WebDAV: Create Folder
echo "--- [3] WebDAV Create Folder ---"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X MKCOL -u "$AUTH" "$HOST/files/user/e2e-files")
if [ "$STATUS" -eq 201 ] || [ "$STATUS" -eq 405 ]; then
    echo "OK ($STATUS)"
else
    echo "FAIL: $STATUS"
    exit 1
fi

# 4. WebDAV: Put File
echo "--- [4] WebDAV Put File ---"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -u "$AUTH" -d "Hello E2E" "$HOST/files/user/e2e-files/doc.txt")
check_status "$STATUS" 201 # Or 204

# 5. WebDAV: Get File
echo "--- [5] WebDAV Get File ---"
CONTENT=$(curl -s -u "$AUTH" "$HOST/files/user/e2e-files/doc.txt")
if [ "$CONTENT" == "Hello E2E" ]; then
    echo "OK (Content match)"
else
    echo "FAIL: Content mismatch: '$CONTENT'"
    exit 1
fi

# 6. WebDAV: Move File
echo "--- [6] WebDAV Move File ---"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X MOVE -u "$AUTH" -H "Destination: $HOST/files/user/e2e-files/moved.txt" "$HOST/files/user/e2e-files/doc.txt")
check_status "$STATUS" 201 # Or 204

# 7. CardDAV: Create Contact
echo "--- [7] CardDAV Create Contact ---"
VCARD="BEGIN:VCARD
VERSION:4.0
UID:e2e-contact
FN:E2E Contact
N:Contact;E2E;;;
EMAIL:e2e@example.com
END:VCARD"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -u "$AUTH" -H "Content-Type: text/vcard" -d "$VCARD" "$HOST/addressbooks/user/default/e2e.vcf")
check_status "$STATUS" 201 # Or 204

echo "=== All Tests Passed ==="

