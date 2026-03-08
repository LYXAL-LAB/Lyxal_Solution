# LYXAL PROXY - FULL ARCHITECTURAL COMPLIANCE AUDIT (GOOGLE-GRADE)
**Project:** Lyxal Solution Backend - Proxy Module (Sōzu Integration)
**Reference:** Protobuf Definitions (`command.rs`) vs. SurrealDB Schema (`*.surql`)
**Status:** DRAFT - PENDING REMEDIATION

---

## 1. EXECUTIVE SUMMARY
This audit evaluates the data structural alignment between the **Sōzu core engine** (represented by its Protobuf/Rust definitions) and the **Lyxal Database Schema**. The goal is to ensure "Zero-Error" bi-directional mapping for AI-driven infrastructure management (MCP).

---

## 2. COMPONENT AUDIT: INGRESS LAYER (FRONTENDS)
*Target: `proxy_ingress` vs. `RequestHttpFrontend` / `RequestTcpFrontend`*

| Protobuf Requirement | SurrealDB Mapping | Status | Gap / Recommendation |
| :--- | :--- | :--- | :--- |
| `hostname` (String) | `configuration.hostname` | **OK** | N/A |
| `address` (SocketAddr) | `configuration.port` | **PARTIAL** | Sōzu requires an IP:Port. Schema currently only stores port. |
| `path` (PathRule) | **MISSING** | 🔴 **CRITICAL** | Required for URL-based routing (Prefix/Regex). Add `configuration.path` & `configuration.path_kind`. |
| `method` (String) | **MISSING** | 🟡 **MINOR** | Optional filtering for REST APIs (GET/POST). Add `configuration.method`. |
| `position` (Enum) | **MISSING** | 🟡 **MINOR** | Internal Sōzu tree position (PRE/POST/TREE). Default to `TREE`. |
| `tags` (Map) | `application.lyxal_proxy` | **OK** | Used to store metadata for MCP context. |

---

## 3. COMPONENT AUDIT: ROUTING LAYER (CLUSTERS)
*Target: `proxy_cluster` vs. `Cluster`*

| Protobuf Requirement | SurrealDB Mapping | Status | Gap / Recommendation |
| :--- | :--- | :--- | :--- |
| `cluster_id` (String) | `id` | **OK** | Ensure Record ID is stripped of prefix when sent to Sōzu. |
| `sticky_session` (Bool) | `configuration.sticky_session`| **OK** | N/A |
| `https_redirect` (Bool) | **MISSING** | 🔴 **CRITICAL** | Essential for automated security. Add `configuration.https_redirect`. |
| `load_balancing` (Enum) | `configuration.load_balancing`| **OK** | Validate against `proxy_cluster_load_balancing` table. |
| `answer_503` (String) | **MISSING** | 🟡 **MINOR** | Allows custom maintenance pages. Add `configuration.maintenance_page`. |
| `load_metric` (Enum) | **MISSING** | 🟡 **MINOR** | For advanced LB (Peak EWMA). Add `configuration.load_metric`. |

---

## 4. COMPONENT AUDIT: BACKEND LAYER (TARGETS)
*Target: `proxy_backend` vs. `AddBackend`*

| Protobuf Requirement | SurrealDB Mapping | Status | Gap / Recommendation |
| :--- | :--- | :--- | :--- |
| `backend_id` (String) | `id` | **OK** | N/A |
| `address` (SocketAddr) | `configuration.address` | **OK** | Ensure backend IP:Port string is valid. |
| `weight` (Int32) | `configuration.weight` | **OK** | N/A |
| `backup` (Bool) | **MISSING** | 🟡 **MINOR** | Critical for failover apps. Add `configuration.is_backup`. |
| `sticky_id` (String) | **MISSING** | 🟡 **MINOR** | For precise session persistence. Add `configuration.sticky_id`. |

---

## 5. COMPONENT AUDIT: SECURITY LAYER (TLS/SSL)
*Target: `proxy_certificate_ssl` vs. `AddCertificate`*

| Protobuf Requirement | SurrealDB Mapping | Status | Gap / Recommendation |
| :--- | :--- | :--- | :--- |
| `certificate` (String) | **MISSING** | 🔴 **CRITICAL** | **NO TABLE FOUND.** Create `proxy_certificate_ssl` to store fullchain. |
| `key` (String) | **MISSING** | 🔴 **CRITICAL** | **NO TABLE FOUND.** Create `proxy_certificate_ssl` to store private keys. |
| `expired_at` (Int64) | **MISSING** | 🔴 **CRITICAL** | Required for AI renewal alerts. Add `timestamp.expires_at`. |
| `versions` (Repeated) | **MISSING** | 🟡 **MINOR** | TLS 1.2 vs 1.3 control. Add `configuration.tls_versions`. |

---

## 6. COMPONENT AUDIT: OBSERVABILITY (METRICS)
*Target: `proxy_metrics` vs. `AggregatedMetrics` / `FilteredMetrics`*

| Protobuf Requirement | SurrealDB Mapping | Status | Gap / Recommendation |
| :--- | :--- | :--- | :--- |
| `gauge` / `count` | `metrics.*` | **OK** | Ensure `to_filtered()` output matches table structure. |
| `percentiles` (Object) | **MISSING** | 🟡 **MINOR** | Vital for performance AI. Add fields for P50, P90, P99 in metrics table. |
| `histogram` (Object) | **MISSING** | 🟡 **MINOR** | Advanced traffic analysis. Add as JSON object field. |

---

## 7. SYSTEM SETTINGS & LISTENERS
*Target: `proxy_settings` vs. `ServerConfig` / `HttpListenerConfig`*

| Protobuf Requirement | SurrealDB Mapping | Status | Gap / Recommendation |
| :--- | :--- | :--- | :--- |
| `max_connections` | **MISSING** | 🔴 **CRITICAL** | **NO TABLE FOUND.** Need global settings table for Sōzu initialization. |
| `front_timeout` | **MISSING** | 🟡 **MINOR** | Control idle connections per listener. |
| `buffer_size` | **MISSING** | 🟡 **MINOR** | Optimization for large payloads. |

---

## 8. REMEDIATION ROADMAP (FOR AI / MCP)
1. **CREATE** `proxy_certificate_ssl.surql`: Crucial for any HTTPS app.
2. **CREATE** `proxy_settings.surql`: Global engine control.
3. **ALTER** `proxy_ingress.surql`: Add `path`, `path_kind`.
4. **ALTER** `proxy_cluster.surql`: Add `https_redirect`.
5. **ALTER** `proxy_backend.surql`: Add `is_backup`.

---
**Auditor Signature:** Lyxal AI Proxy Engine (Goose)
**Date:** March 7, 2026
