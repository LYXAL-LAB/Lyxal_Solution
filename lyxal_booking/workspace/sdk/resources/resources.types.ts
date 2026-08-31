/**
 * 🏛️ LYXAL OS — Types TypeScript pour le Module 05 : Resources
 * Dérivés des contrats Rust DTOs (engine/src/contracts/resources.rs)
 */

export interface ResourceResponse {
  id: string;
  name: string;
  resource_type: 'ROOM' | 'EQUIPMENT' | 'VEHICLE' | string;
  capacity?: number | null;
  location?: string | null;
  description?: string | null;
  feed_url?: string | null;
  enabled: boolean;
}

export interface CreateResourceRequest {
  name: string;
  resource_type: string;
  capacity?: number | null;
  location?: string | null;
  description?: string | null;
  feed_url?: string | null;
}

export interface UpdateResourceRequest {
  name: string;
  resource_type: string;
  capacity?: number | null;
  location?: string | null;
  description?: string | null;
  feed_url?: string | null;
}

export interface DeleteResourceResponse {
  deleted: boolean;
}

export interface SyncResourceResponse {
  resource_id: string;
  synchronized_events: number;
}
