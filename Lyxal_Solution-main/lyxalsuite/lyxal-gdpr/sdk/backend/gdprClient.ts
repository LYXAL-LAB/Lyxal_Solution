import { HttpClient } from '../../../lyxalbase/sdk/httpClient';
import type {
  CreateGdprRequestInput,
  UpdateGdprRequestInput,
  CreateGdprResponseInput,
  GdprRequest,
  GdprResponse,
  GdprLog,
} from '../types/types';

export class GdprClient {
  constructor(private client: HttpClient) {}

  async createRequest(data: CreateGdprRequestInput): Promise<GdprRequest> {
    return this.client.post('/gdpr/request', data);
  }

  async getRequest(id: string): Promise<GdprRequest> {
    return this.client.get(`/gdpr/request/${id}`);
  }

  async listRequests(): Promise<GdprRequest[]> {
    return this.client.get('/gdpr/request');
  }

  async updateRequest(id: string, data: UpdateGdprRequestInput): Promise<GdprRequest> {
    return this.client.put(`/gdpr/request/${id}`, data);
  }

  async deleteRequest(id: string): Promise<void> {
    await this.client.delete(`/gdpr/request/${id}`);
  }

  async createResponse(requestId: string, data: CreateGdprResponseInput): Promise<GdprResponse> {
    return this.client.post(`/gdpr/response/${requestId}`, data);
  }

  async listLogs(): Promise<GdprLog[]> {
    return this.client.get('/gdpr/logs');
  }
}
