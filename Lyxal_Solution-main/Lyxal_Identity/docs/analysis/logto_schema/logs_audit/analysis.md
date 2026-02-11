# Logs & Audit Schema Analysis

## 1. Logs (`logs.sql`)
**Logto:** Generic event log.
**Lyxal Strategy:** `audit_log` table (already exists).

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `key` | varchar | `audit_log.event` | Event name |
| `payload` | jsonb | `audit_log.details` | |
| `created_at` | timestamp | `audit_log.created_at` | |

## Action Items
1. [ ] Enhance `audit_log` to support structured payloads.
