import axios from "axios";
const CLOUD_API_BASE_URL = "https://api.cloud.surrealdb.com/api/v1";
export class CloudClient {
    client;
    authToken;
    refreshToken;
    constructor(authToken, refreshToken) {
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
    async listOrganizations() {
        const res = await this.client.get("/organizations");
        return res.data;
    }
    async listInstances(orgId) {
        const res = await this.client.get(`/organizations/${orgId}/instances`);
        return res.data;
    }
    async createInstance(orgId, name) {
        const res = await this.client.post(`/organizations/${orgId}/instances`, {
            name,
            organization_id: orgId,
        });
        return res.data.instance;
    }
    async getInstanceAuth(instanceId) {
        const res = await this.client.get(`/instances/${instanceId}/auth`);
        return res.data.token;
    }
    async getInstanceStatus(instanceId) {
        const res = await this.client.get(`/instances/${instanceId}/status`);
        return res.data;
    }
    async pauseInstance(instanceId) {
        const res = await this.client.post(`/instances/${instanceId}/pause`);
        return res.data;
    }
    async resumeInstance(instanceId) {
        const res = await this.client.post(`/instances/${instanceId}/resume`);
        return res.data;
    }
}
