import { SurrealClient } from '../../../lyxalsurreal';
import { logAuditEvent } from '../utils/logAuditEvent';
import type {
  CreateGdprRequestInput,
  UpdateGdprRequestInput,
  CreateGdprResponseInput,
  GdprRequest,
  GdprResponse,
  GdprLog,
} from '../../../lyxalgdpr/sdk/types/types';

// Obtenir l'instance du client depuis le contexte
const getDb = (ctx: any) => ctx.get('db') || null;

export class GdprService {
  static async createRequest(ctx: any, data: CreateGdprRequestInput): Promise<GdprRequest> {
    const db = getDb(ctx);
    if (!db) throw new Error('Database client not available in context');
    
    const record = await db.create('gdpr_request', data);
    await logAuditEvent(ctx, 'gdpr:request_created', record);
    return record;
  }

  static async getRequest(ctx: any, id: string): Promise<GdprRequest> {
    const db = getDb(ctx);
    if (!db) throw new Error('Database client not available in context');
    
    return await db.select(`gdpr_request:${id}`);
  }

  static async listRequests(ctx: any): Promise<GdprRequest[]> {
    const db = getDb(ctx);
    if (!db) throw new Error('Database client not available in context');
    
    return await db.select('gdpr_request');
  }

  static async updateRequest(ctx: any, id: string, data: UpdateGdprRequestInput): Promise<GdprRequest> {
    const db = getDb(ctx);
    if (!db) throw new Error('Database client not available in context');
    
    const updated = await db.merge(`gdpr_request:${id}`, data);
    await logAuditEvent(ctx, 'gdpr:request_updated', updated);
    return updated;
  }

  static async deleteRequest(ctx: any, id: string): Promise<void> {
    const db = getDb(ctx);
    if (!db) throw new Error('Database client not available in context');
    
    await db.delete(`gdpr_request:${id}`);
    await logAuditEvent(ctx, 'gdpr:request_deleted', { id });
  }

  static async createResponse(ctx: any, requestId: string, data: CreateGdprResponseInput): Promise<GdprResponse> {
    const db = getDb(ctx);
    if (!db) throw new Error('Database client not available in context');
    
    const response = await db.create('gdpr_response', {
      ...data,
      request: `gdpr_request:${requestId}`,
    });
    await logAuditEvent(ctx, 'gdpr:response_created', response);
    return response;
  }

  static async listLogs(ctx: any): Promise<GdprLog[]> {
    const db = getDb(ctx);
    if (!db) throw new Error('Database client not available in context');
    
    return await db.select('gdpr_processing_register_log');
  }
}