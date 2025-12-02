import axios, { type AxiosInstance } from "axios";

const CLOUD_API_BASE_URL = "https://api.cloud.surrealdb.com/api/v1";

export interface CloudInstance {
  id: string;
  name: string;
  slug?: string;
  version?: string;
  available_versions?: string[];
  host?: string;
  region?: string;
  organization_id?: string;
  state?: string;
  compute_units?: number;
  storage_size?: number;
  can_update_storage_size?: boolean;
  storage_size_update_cooloff_hours?: number;
}

export interface CloudPlan {
  id: string;
  name: string;
  description: string;
  regions: string[];
}

export interface CloudOrganization {
  id: string;
  name: string;
  user_role?: string;
  billing_info?: boolean;
  payment_info?: boolean;
  max_free_instances?: number;
  max_paid_instances?: number;
  member_count?: number;
  plan?: CloudPlan;
}

export interface CloudInstanceBackup {
  snapshot_started_at: string;
  snapshot_id: string;
}

export interface CloudInstanceStatus {
  phase: string;
  db_backups: CloudInstanceBackup[];
}

export class CloudClient {
  private client: AxiosInstance;
  private authToken?: string;
  private refreshToken?: string;

  constructor(authToken?: string, refreshToken?: string) {
    this.authToken = authToken;
    this.refreshToken = refreshToken;
    this.client = axios.create({
      baseURL: CLOUD_API_BASE_URL,
      headers: {
        "Content-Type": "application/json",
      },
    });

    // Interceptor pour ajouter le token
    this.client.interceptors.request.use((config) => {
      if (this.authToken) {
        config.headers.Authorization = `Bearer ${this.authToken}`;
      }
      return config;
    });
  }

  async listOrganizations(): Promise<CloudOrganization[]> {
    const res = await this.client.get("/organizations");
    return res.data;
  }

  async listInstances(orgId: string): Promise<CloudInstance[]> {
    const res = await this.client.get(`/organizations/${orgId}/instances`);
    return res.data;
  }

  async createInstance(orgId: string, name: string): Promise<CloudInstance> {
    const res = await this.client.post(`/organizations/${orgId}/instances`, {
      name,
      organization_id: orgId,
    });
    return res.data.instance;
  }

  async getInstanceAuth(instanceId: string): Promise<string> {
    const res = await this.client.get(`/instances/${instanceId}/auth`);
    return res.data.token;
  }

  async getInstanceStatus(instanceId: string): Promise<CloudInstanceStatus> {
    const res = await this.client.get(`/instances/${instanceId}/status`);
    return res.data;
  }

  async pauseInstance(instanceId: string): Promise<CloudInstance> {
    const res = await this.client.post(`/instances/${instanceId}/pause`);
    return res.data;
  }

  async resumeInstance(instanceId: string): Promise<CloudInstance> {
    const res = await this.client.post(`/instances/${instanceId}/resume`);
    return res.data;
  }
}
