$base = "http://127.0.0.1:3000"

Write-Host "1. GET Root"
& curl.exe -v "$base/"

Write-Host "`n2. PUT Event"
$body = "BEGIN:VCALENDAR`nVERSION:2.0`nBEGIN:VEVENT`nUID:event1`nDTSTART:20250101T100000Z`nDURATION:PT1H`nSUMMARY:Test Event`nEND:VEVENT`nEND:VCALENDAR"
& curl.exe -v -X PUT "$base/calendar/event1.ics" -H "Content-Type: text/calendar" -d "$body"

Write-Host "`n3. REPORT TimeRange"
$xml = "<C:calendar-query xmlns:C='urn:ietf:params:xml:ns:caldav'><C:filter><C:comp-filter name='VCALENDAR'><C:comp-filter name='VEVENT'><C:time-range start='20250101T000000Z' end='20250102T000000Z'/></C:comp-filter></C:comp-filter></C:filter></C:calendar-query>"
& curl.exe -v -X REPORT "$base/calendar" -H "Content-Type: application/xml" -H "Depth: 1" -d "$xml"
