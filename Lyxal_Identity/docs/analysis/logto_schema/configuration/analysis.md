# Configuration Schema Analysis

## 1. Logto Configs (`logto_configs.sql`)
**Logto:** Key-value store for system config.
**Lyxal Strategy:** `configuration` table or `system_settings`.

| Field | Type | Lyxal Location | Notes |
|---|---|---|---|
| `key` | varchar | `configuration.key` | |
| `value` | jsonb | `configuration.value` | |

## Action Items
1. [ ] Create `configuration` table.
