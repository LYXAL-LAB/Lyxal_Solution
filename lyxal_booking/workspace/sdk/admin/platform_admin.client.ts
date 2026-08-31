/**
 * 🏛️ LYXAL OS — SDK Client Platform SuperAdmin
 */

import { HttpClient, httpClient } from '../client';
import {
  PlatformMetricsResponse,
  PlatformTenantsPage,
  PlatformUsersPage,
  PlatformAuditLogsPage,
  PlatformSettingsResponse,
  UpdatePlatformSettingsRequest,
} from './admin.types';

export class PlatformAdminClient {
  private client: HttpClient;

  constructor(client: HttpClient = httpClient) {
    this.client = client;
  }

  public async getMetrics(): Promise<PlatformMetricsResponse> {
    return this.client.get<PlatformMetricsResponse>('/platform-admin/metrics');
  }

  public async listTenants(limit?: number): Promise<PlatformTenantsPage> {
    const q = limit ? `?limit=${limit}` : '';
    return this.client.get<PlatformTenantsPage>(`/platform-admin/tenants${q}`);
  }

  public async listUsers(limit?: number): Promise<PlatformUsersPage> {
    const q = limit ? `?limit=${limit}` : '';
    return this.client.get<PlatformUsersPage>(`/platform-admin/users${q}`);
  }

  public async getAuditLogs(limit?: number): Promise<PlatformAuditLogsPage> {
    const q = limit ? `?limit=${limit}` : '';
    return this.client.get<PlatformAuditLogsPage>(`/platform-admin/audit-logs${q}`);
  }

  public async getSettings(): Promise<PlatformSettingsResponse> {
    return this.client.get<PlatformSettingsResponse>('/platform-admin/settings');
  }

  public async updateSettings(request: UpdatePlatformSettingsRequest): Promise<PlatformSettingsResponse> {
    return this.client.patch<PlatformSettingsResponse>('/platform-admin/settings', request);
  }
}

export const platformAdminClient = new PlatformAdminClient();
