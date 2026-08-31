# 📘 Module 11 — Admin System & Platform Supervision (Lyxal OS)

## 📌 Vue d'Ensemble
Le module **Admin System & Platform Supervision** gère la supervision de la plateforme, l'administration au niveau Tenant et la supervision globale au niveau Platform SuperAdmin.

---

## 🏛️ Architecture & Contrats

### 1. Tenant Admin (`/api/v1/admin/*`)
- **REST API v1** : [`engine/src/web/api/v1/admin.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/admin.rs)
  - `GET /api/v1/admin/metrics`
  - `GET /api/v1/admin/users`
  - `PATCH /api/v1/admin/users/{user_id}/role`
  - `GET /api/v1/admin/audit-logs`
  - `GET /api/v1/admin/settings`
  - `PATCH /api/v1/admin/settings`
- **SurrealQL Primitives** : `fn::booking_admin_get_tenant_metrics`, `fn::booking_admin_list_tenant_users`, `fn::booking_admin_update_tenant_user_role`, `fn::booking_admin_get_tenant_audit_logs`, `fn::booking_admin_get_tenant_settings`, `fn::booking_admin_update_tenant_settings`.

### 2. Platform SuperAdmin (`/api/v1/platform-admin/*`)
- **REST API v1** : [`engine/src/web/api/v1/platform_admin.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/platform_admin.rs)
  - `GET /api/v1/platform-admin/metrics`
  - `GET /api/v1/platform-admin/tenants`
  - `GET /api/v1/platform-admin/users`
  - `GET /api/v1/platform-admin/audit-logs`
  - `GET /api/v1/platform-admin/settings`
  - `PATCH /api/v1/platform-admin/settings`
- **SurrealQL Primitives** : `fn::booking_platform_get_metrics`, `fn::booking_platform_list_tenants`, `fn::booking_platform_list_users`, `fn::booking_platform_get_audit_logs`, `fn::booking_platform_get_settings`, `fn::booking_platform_update_settings`.

---

## 🔒 SDK & UI Workspace
- **SDK Clients** : [`workspace/sdk/admin/tenant_admin.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/admin/tenant_admin.client.ts) & [`workspace/sdk/admin/platform_admin.client.ts`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/sdk/admin/platform_admin.client.ts).
- **UI React Modulaire** : [`workspace/modules/admin/AdminPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/admin/AdminPage.tsx) avec bascule Tenant / SuperAdmin.

---

## 🔒 Statut de Complétude
- Backend & REST API v1 (Tenant Admin + Platform SuperAdmin) : **`● VALIDÉ`**
- SDK Client TypeScript (Tenant & Platform Clients) : **`● VALIDÉ`**
- UI React Workspace (Panneaux Métriques, Utilisateurs, Audit Logs, Settings) : **`● IMPLÉMENTÉE (READY FOR REVIEW)`**
- **STATUT GLOBAL** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**
