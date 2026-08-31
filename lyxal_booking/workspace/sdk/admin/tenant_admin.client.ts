/**
 * 🏛️ LYXAL OS — SDK Client Tenant Admin
 */

import { HttpClient, httpClient } from '../client';
import {
  TenantMetricsResponse,
  TenantUsersPage,
  UpdateTenantUserRoleRequest,
  TenantAuditLogsPage,
  TenantSettingsResponse,
  UpdateTenantSettingsRequest,
} from './admin.types';

export class TenantAdminClient {
  private client: HttpClient;

  constructor(client: HttpClient = httpClient) {
    this.client = client;
  }

  public async getMetrics(): Promise<TenantMetricsResponse> {
    return this.client.get<TenantMetricsResponse>('/admin/metrics');
  }

  public async listUsers(limit?: number): Promise<TenantUsersPage> {
    const q = limit ? `?limit=${limit}` : '';
    return this.client.get<TenantUsersPage>(`/admin/users${q}`);
  }

  public async updateUserRole(userId: string, request: UpdateTenantUserRoleRequest): Promise<{ user_id: string; new_role: string; updated: boolean }> {
    return this.client.patch<{ user_id: string; new_role: string; updated: boolean }>(`/admin/users/${encodeURIComponent(userId)}/role`, request);
  }

  public async getAuditLogs(limit?: number): Promise<TenantAuditLogsPage> {
    const q = limit ? `?limit=${limit}` : '';
    return this.client.get<TenantAuditLogsPage>(`/admin/audit-logs${q}`);
  }

  public async getSettings(): Promise<TenantSettingsResponse> {
    return this.client.get<TenantSettingsResponse>('/admin/settings');
  }

  public async updateSettings(request: UpdateTenantSettingsRequest): Promise<TenantSettingsResponse> {
    return this.client.patch<TenantSettingsResponse>('/admin/settings', request);
  }
}

export const tenantAdminClient = new TenantAdminClient();
