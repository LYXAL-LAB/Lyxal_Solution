# Guide de Migration : De n8n vers Lyxal Connector

| Concept n8n | Equivalent Lyxal (Lyxal) |
| :--- | :--- |
| Node (ex: Google Sheets) | `DEFINE CONNECTOR gsheets` |
| Credentials (OAuth2) | `DEFINE ACCESS ... TYPE OAUTH2` |
| Mapping JS | Expressions LyxalQL natives |
| Error Trigger | Bloc `ON ERROR { ... }` |
| Cron Trigger | `DEFINE EVENT` ou `SLEEP` |

## Exemple de transformation
N8N POST -> https://api.slack.com/methods/chat.postMessage
DEVIENT :
```sql
DEFINE CONNECTOR slack TYPE 'http'
    FOR post_message THEN {
        RETURN http::post("https://slack.com/api/chat.postMessage", $body);
    };
```