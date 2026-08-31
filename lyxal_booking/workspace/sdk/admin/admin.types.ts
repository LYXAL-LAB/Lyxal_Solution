/**
 * 🏛️ LYXAL OS — Types SDK pour Tenant Admin & Platform SuperAdmin
 */

export interface TenantMetricsResponse {
  total_users: number;
  total_bookings: number;
  pending_bookings: number;
  confirmed_bookings: number;
  cancelled_bookings: number;
}

export interface TenantAdminUserItem {
  id: string;
  email: string;
  name: string;
  role: string;
  created_at: string;
}

export interface TenantUsersPage {
  users: TenantAdminUserItem[];
  limit: number;
}

export interface UpdateTenantUserRoleRequest {
  role: string;
}

export interface TenantAuditLogEntry {
  id: string;
  actor_id: string;
  action: string;
  target_id?: string;
  new_role?: string;
  created_at: string;
}

export interface TenantAuditLogsPage {
  logs: TenantAuditLogEntry[];
  limit: number;
}

export interface TenantSettingsResponse {
  tenant_id: string;
  branding_name: string;
  default_timezone: string;
  allow_public_bookings: boolean;
}

export interface UpdateTenantSettingsRequest {
  branding_name?: string;
  default_timezone?: string;
  allow_public_bookings?: boolean;
}

export interface PlatformMetricsResponse {
  total_tenants: number;
  total_users: number;
  total_bookings: number;
  total_audit_logs: number;
  system_status: string;
}

export interface PlatformTenantItem {
  id: string;
  name: string;
  created_at: string;
}

export interface PlatformTenantsPage {
  tenants: PlatformTenantItem[];
  limit: number;
}

export interface PlatformUserItem {
  id: string;
  email: string;
  name: string;
  role: string;
  tenant_id: string;
  created_at: string;
}

export interface PlatformUsersPage {
  users: PlatformUserItem[];
  limit: number;
}

export interface PlatformAuditLogEntry {
  id: string;
  tenant_id: string;
  actor_id: string;
  action: string;
  target_id?: string;
  new_role?: string;
  created_at: string;
}

export interface PlatformAuditLogsPage {
  logs: PlatformAuditLogEntry[];
  limit: number;
}

export interface PlatformSettingsResponse {
  maintenance_mode: boolean;
  max_users_per_tenant: number;
  audit_retention_days: number;
  security_policy: string;
}

export interface UpdatePlatformSettingsRequest {
  maintenance_mode?: boolean;
  max_users_per_tenant?: number;
  audit_retention_days?: number;
  security_policy?: string;
}
