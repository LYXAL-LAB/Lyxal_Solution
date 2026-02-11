import { GdprClient as BaseGdprClient } from '../backend/gdprClient';
import { HttpClient } from '../../../lyxalbase/sdk/httpClient';
import type {
  GdprRequest,
  GdprResponse,
  GdprLog,
  CreateGdprRequestInput,
  UpdateGdprRequestInput,
  CreateGdprResponseInput
} from '../types/types';

// Instance singleton pour le frontend
let clientInstance: GdprClient | null = null;

export class GdprClient extends BaseGdprClient {
  /**
   * Obtenir l'instance unique du client frontend
   */
  static getInstance(): GdprClient {
    if (!clientInstance) {
      // Créer une nouvelle instance avec l'URL de base de l'API
      const apiUrl = process.env.REACT_APP_API_URL || '/api';
      const httpClient = new HttpClient(apiUrl);
      clientInstance = new GdprClient(httpClient);
    }
    return clientInstance;
  }
}

// Exporter une instance par défaut pour faciliter l'utilisation
export const gdprClient = GdprClient.getInstance();
