/**
 * 🎯 Implémentation Interface Simple
 * 
 * Classe qui récupère les données de connexion + streaming automatique
 */

import { LyxalSurrealClient, defaultConfig } from '@lyxalsuite/lyxal-surreal';
import type { LyxalInterface, ConnectionData } from './types/interface.js';

export class LyxalInterfaceImpl implements LyxalInterface {
  public data: ConnectionData | null = null;
  public isConnected: boolean = false;
  public isStreaming: boolean = false;
  public onUpdate?: (data: ConnectionData) => void;

  private client: LyxalSurrealClient;
  private liveQueries: any[] = [];

  constructor() {
    this.client = new LyxalSurrealClient(defaultConfig);
  }

  /**
   * Se connecte et récupère les données initiales
   */
  async connect(platformId?: string): Promise<ConnectionData> {
    try {
      // Initialise la connexion si nécessaire
      await this.client.initialize();

      // Vérifie si MASTER est configuré
      const isConfigured = await this.client.master.isMasterLevelConfigured();
      if (!isConfigured) {
        throw new Error('Niveau MASTER non configuré');
      }

      let identity, infrastructure;

      if (platformId) {
        // Charge une plateforme spécifique
        const platform = await this.client.master.getMasterPlatform(platformId);
        identity = platform.identity;
        infrastructure = platform.infrastructure;
      } else {
        // Charge la première plateforme disponible
        const platforms = await this.client.master.listMasterPlatforms();
        if (platforms.identities.length === 0) {
          throw new Error('Aucune plateforme MASTER trouvée');
        }
        identity = platforms.identities[0]!;
        infrastructure = platforms.infrastructures[0]!;
      }

      const connectionData: ConnectionData = {
        identity,
        infrastructure,
        lastUpdate: new Date()
      };

      this.data = connectionData;
      this.isConnected = true;

      return connectionData;

    } catch (error) {
      this.isConnected = false;
      throw error;
    }
  }

  /**
   * Active le streaming pour les mises à jour automatiques
   */
  async startStreaming(): Promise<void> {
    if (!this.data || this.isStreaming) return;

    try {
      const baseClient = this.client.getBaseClient();
      const db = baseClient.getDB();
      const platformId = this.data.identity.platform_id;

      // Streaming sur system_identity
      const identityQuery = await db.live(
        `LIVE SELECT * FROM system_identity WHERE platform_id = '${platformId}'`,
        (action: string, result: any) => {
          if (action === 'UPDATE' && result && this.data) {
            this.data = {
              ...this.data,
              identity: result,
              lastUpdate: new Date()
            };
            this.onUpdate?.(this.data);
          }
        }
      );

      // Streaming sur system_infrastructure
      const infraQuery = await db.live(
        `LIVE SELECT * FROM system_infrastructure WHERE platform_id = '${platformId}'`,
        (action: string, result: any) => {
          if (action === 'UPDATE' && result && this.data) {
            this.data = {
              ...this.data,
              infrastructure: result,
              lastUpdate: new Date()
            };
            this.onUpdate?.(this.data);
          }
        }
      );

      this.liveQueries = [identityQuery, infraQuery];
      this.isStreaming = true;

    } catch (error) {
      console.error('Erreur activation streaming:', error);
      throw error;
    }
  }

  /**
   * Arrête le streaming
   */
  async stopStreaming(): Promise<void> {
    if (!this.isStreaming) return;

    try {
      const baseClient = this.client.getBaseClient();
      const db = baseClient.getDB();
      await Promise.all(this.liveQueries.map(queryId => db.kill(queryId)));
      this.liveQueries = [];
      this.isStreaming = false;
    } catch (error) {
      console.error('Erreur arrêt streaming:', error);
      throw error;
    }
  }

  /**
   * Nettoyage
   */
  async destroy(): Promise<void> {
    if (this.isStreaming) {
      await this.stopStreaming();
    }
    await this.client.close();
    this.data = null;
    this.isConnected = false;
  }
} 